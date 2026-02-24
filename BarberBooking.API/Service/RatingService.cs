using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Domain;
using BarberBooking.API.Domain.MasterDomain;
using BarberBooking.API.Domain.SalonDomain;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.Service
{
    public class RatingService:IRatingService
    {
        private readonly ISalonsRepository _salonsRepository;
        private readonly IMasterProfileRepository _masterProfileRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IKafkaProducerSalonEvent<SalonAddRatingEvent> _kafkaProducerSalon;
        private readonly IKafkaProducerSalonEvent<MasterAddRatingEvent> _kafkaProducerMaster;
        private readonly IEventStoreRepository _eventStoreRepository;
        public RatingService(ISalonsRepository salonsRepository, IMasterProfileRepository masterProfileRepository, IUnitOfWork unitOfWork, IKafkaProducerSalonEvent<SalonAddRatingEvent> kafkaProducerSalon,IKafkaProducerSalonEvent<MasterAddRatingEvent> kafkaProducerMaster ,IEventStoreRepository eventStoreRepository)
        {
            _salonsRepository = salonsRepository;
            _masterProfileRepository = masterProfileRepository;
            _unitOfWork = unitOfWork;
            _kafkaProducerSalon = kafkaProducerSalon;
            _kafkaProducerMaster = kafkaProducerMaster;
            _eventStoreRepository = eventStoreRepository;
        }

        public async Task<Result> AddMasterRating(Guid MasterId, int MasterRating, CancellationToken cancellationToken)
        {
            var master = await _masterProfileRepository.GetMasterProfileById(MasterId);
            if(master == null)
                return Result.Failure("Мастер не найден");
            int ratingCount = master.RatingCount + 1;
            var newAverage = ((master.Rating * master.RatingCount) + MasterRating) / (master.RatingCount + 1);
            var domainEvent = new MasterAddRatingEvent(MasterId, newAverage, ratingCount);
            try
            {
                _unitOfWork.BeginTransaction();
                master.AddRating(newAverage, ratingCount);
                await _eventStoreRepository.SaveEventsAsync(domainEvent.AggregateId, new List<DomainEvent>{domainEvent});
                _unitOfWork.Commit();
            }catch(Exception e)
            {
                _unitOfWork.RollBack();
                return Result.Failure(e.Message);
            }
            await _kafkaProducerMaster.ProduceAsync(domainEvent, cancellationToken);
            return Result.Success();
        }

        public async Task<Result> AddSalonRating(Guid SalonId, int SalonRating, CancellationToken cancellationToken)
        {
            var salon = await _salonsRepository.GetSalonById(SalonId);
            if(salon == null)
                return Result.Failure("Салон не найден");
            int ratingCount = salon.RatingCount + 1;
            var newAverage = ((salon.Rating * salon.RatingCount) + SalonRating) / ratingCount;

            var domainEvent = new SalonAddRatingEvent(SalonId, newAverage, ratingCount);
            try
            {
                _unitOfWork.BeginTransaction();
                salon.AddRating(newAverage, ratingCount);
                await _eventStoreRepository.SaveEventsAsync(domainEvent.AggregateId, new List<DomainEvent>{domainEvent});
                _unitOfWork.Commit();
            }catch(Exception e)
            {
                _unitOfWork.RollBack();
                return Result.Failure(e.Message);
            }
            await _kafkaProducerSalon.ProduceAsync(domainEvent, cancellationToken);
            return Result.Success();
        }
    }
}