using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Domain;
using BarberBooking.API.Domain.MasterDomain;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Service
{
    public class RatingCreateMasterService : IRatingCreateMasterService
    {
        private readonly IMasterProfileRepository _masterProfileRepository;
        private readonly IKafkaProducerSalonEvent<MasterAddRatingEvent> _kafkaProducerSalonEvent;
        private readonly IEventStoreRepository _eventStoreRepository;
        public RatingCreateMasterService(IMasterProfileRepository masterProfileRepository, IKafkaProducerSalonEvent<MasterAddRatingEvent> kafkaProducerSalonEvent, IEventStoreRepository eventStoreRepository)
        {
            _masterProfileRepository = masterProfileRepository;
            _kafkaProducerSalonEvent = kafkaProducerSalonEvent;
            _eventStoreRepository = eventStoreRepository;
        }
        public async Task<Result> AddRating(Guid masterId, CancellationToken cancellationToken)
        {
             var salon = await _masterProfileRepository.GetMasterProfileById(masterId);
            if(salon == null)
                return Result.Success();
            var domainEvent = new MasterAddRatingEvent(masterId, 0, 0);
            try
            {
                await _eventStoreRepository.SaveEventsAsync(masterId, new List<DomainEvent>{domainEvent});
            }catch(Exception ex)
            {
                return Result.Failure(ex.Message);
            }
            return Result.Success();
        }
    }
}