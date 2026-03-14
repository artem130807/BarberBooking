using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Domain;
using BarberBooking.API.Domain.MasterDomain;
using BarberBooking.API.Domain.SalonDomain;
using BarberBooking.API.Models;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Service
{
    public class RollBackRatingService : IRollBackRatingService
    {
        private readonly IEventStoreRepository _eventStoreRepository;
        private readonly ISalonsRepository _salonsRepository;
        private readonly IMasterProfileRepository _masterProfileRepository;
        private readonly IKafkaProducerSalonEvent<SalonRatingRollbackedEvent> _kafkaProducerSalon;
        private readonly IKafkaProducerSalonEvent<MasterRollBackRatingEvent> _kafkaProducerMaster;
        private readonly IReviewRepository _reviewRepository;
        public RollBackRatingService(IEventStoreRepository eventStoreRepository, ISalonsRepository salonsRepository, IKafkaProducerSalonEvent<SalonRatingRollbackedEvent> kafkaProducerSalon,IKafkaProducerSalonEvent<MasterRollBackRatingEvent> kafkaProducerMaster ,IMasterProfileRepository masterProfileRepository, IReviewRepository reviewRepository)
        {
            _eventStoreRepository = eventStoreRepository;
            _salonsRepository = salonsRepository;
            _kafkaProducerSalon = kafkaProducerSalon;
            _masterProfileRepository = masterProfileRepository;
            _reviewRepository = reviewRepository;
            _kafkaProducerMaster = kafkaProducerMaster;
            _kafkaProducerSalon = kafkaProducerSalon;
        }

        public async Task<Result> RollBackMasterRating(Guid AggregateId, Guid reviewId, CancellationToken cancellationToken)
        {
            var reviews = await _reviewRepository.GetListReviewsByMasterId(AggregateId);
            var reviewsExcept = reviews.Where(x => x.Id != reviewId);
            decimal rating = 0;
            int ratingCount = reviewsExcept.Count();
            foreach(var review in reviewsExcept)
            {
                rating += review.SalonRating;
            }
            rating = rating / ratingCount;
            var master = await _masterProfileRepository.GetMasterProfileById(AggregateId);
            master.RollBackRating(rating, ratingCount);
            await _masterProfileRepository.UpdateAsync(master);
            var rollbackEvent = new MasterRollBackRatingEvent(AggregateId, rating, ratingCount);
            await _eventStoreRepository.SaveEventsAsync(AggregateId, new List<DomainEvent>{rollbackEvent});
            await _kafkaProducerMaster.ProduceAsync(rollbackEvent, cancellationToken);
            return Result.Success();
        }

        public async Task<Result> RollBackSalonRating(Guid AggregateId,  Guid reviewId, CancellationToken cancellationToken)
        {
            var reviews = await _reviewRepository.GetListReviewsBySalonId(AggregateId);
            var reviewsExcept = reviews.Where(x => x.Id != reviewId);
            decimal rating = 0;
            int ratingCount = reviewsExcept.Count();
            foreach(var review in reviewsExcept)
            {
                rating += review.SalonRating;
            }
            rating = rating / ratingCount;
            var salon = await _salonsRepository.GetSalonById(AggregateId);
            salon.RollBackRating(rating, ratingCount);
            await _salonsRepository.UpdateAsync(salon);
            var rollbackEvent = new SalonRatingRollbackedEvent(AggregateId, rating, ratingCount);
            await _eventStoreRepository.SaveEventsAsync(AggregateId, new List<DomainEvent>{rollbackEvent});
            await _kafkaProducerSalon.ProduceAsync(rollbackEvent, cancellationToken);
            return Result.Success();
        }
    }
}