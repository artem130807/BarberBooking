using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Domain;
using BarberBooking.API.Domain.SalonDomain;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Service
{
    public class RatingCreateSalonService : IRatingCreateSalonService
    {
        private readonly ISalonsRepository _salonsRepository;
        private readonly IKafkaProducerSalonEvent<SalonAddRatingEvent> _kafkaProducerSalonEvent;
        private readonly IEventStoreRepository _eventStoreRepository;
        public RatingCreateSalonService(ISalonsRepository salonsRepository, IKafkaProducerSalonEvent<SalonAddRatingEvent> kafkaProducerSalonEvent,  IEventStoreRepository eventStoreRepository)
        {
            _salonsRepository = salonsRepository;
            _kafkaProducerSalonEvent = kafkaProducerSalonEvent;
            _eventStoreRepository = eventStoreRepository;
        }
        public async Task<Result> AddRating(Guid salonId, CancellationToken cancellationToken)
        {
            var salon = await _salonsRepository.GetSalonById(salonId);
            if(salon == null)
                return Result.Success();
            var domainEvent = new SalonAddRatingEvent(salonId, 0, 0);
            try
            {
                await _eventStoreRepository.SaveEventsAsync(salonId, new List<DomainEvent>{domainEvent});
            }catch(Exception ex)
            {
                return Result.Failure(ex.Message);
            }
            return Result.Success();
        }
    }
}