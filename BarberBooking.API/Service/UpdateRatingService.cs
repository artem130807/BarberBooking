using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Domain;
using BarberBooking.API.Domain.MasterDomain;
using BarberBooking.API.Domain.SalonDomain;
using BarberBooking.API.Models;

namespace BarberBooking.API.Service
{
    public class UpdateRatingService : IUpdateRatingService
    {
        private readonly ISalonsRepository _salonsRepository;
        private readonly IMasterProfileRepository _masterProfileRepository;
        private readonly IReviewRepository _reviewRepository;
        private readonly IEventStoreRepository _eventStoreRepository;
        public UpdateRatingService(ISalonsRepository salonsRepository, IMasterProfileRepository masterProfileRepository, IReviewRepository reviewRepository,IEventStoreRepository eventStoreRepository)
        {
            _salonsRepository = salonsRepository;
            _masterProfileRepository = masterProfileRepository;
            _reviewRepository = reviewRepository;
            _eventStoreRepository = eventStoreRepository;
        }
        public async Task UpdateMasterRating(Guid aggregateId, Guid reviewId, int? masterRating, CancellationToken cancellationToken)
        {
            var reviews = await _reviewRepository.GetListReviewsByMasterId(aggregateId);
            var reviewsExcept = reviews.Where(x => x.Id != reviewId);
            decimal rating = 0;
            int ratingCount = reviewsExcept.Count() + 1;
            foreach(var review in reviewsExcept)
            {
                rating += review.MasterRating ?? 0;
            }
            rating = (rating + masterRating.Value) / ratingCount;
            var master = await _masterProfileRepository.GetMasterProfileById(aggregateId);
            var domainEvent = new MasterAddRatingEvent(aggregateId, rating, ratingCount);
            await _eventStoreRepository.SaveEventsAsync(aggregateId, new List<DomainEvent> {domainEvent});
            master.AddRating(rating, ratingCount);
        }

        public async Task UpdateSalonRating(Guid aggregateId, Guid reviewId, int? salonRating, CancellationToken cancellationToken)
        {
            var salon = await _salonsRepository.GetSalonById(aggregateId);
            var reviews = await _reviewRepository.GetListReviewsBySalonId(aggregateId);
            var reviewsExcept = reviews.Where(x => x.Id != reviewId);
            decimal rating = 0;
            int ratingCount = reviewsExcept.Count() + 1;
            foreach(var review in reviewsExcept)
            {
                rating += review.SalonRating;
            }
            rating = (rating + salonRating.Value) / ratingCount;
            var domainEvent = new SalonAddRatingEvent(aggregateId, rating, ratingCount);
            await _eventStoreRepository.SaveEventsAsync(aggregateId, new List<DomainEvent> {domainEvent});
            salon.AddRating(rating, ratingCount);
        }
    }
}