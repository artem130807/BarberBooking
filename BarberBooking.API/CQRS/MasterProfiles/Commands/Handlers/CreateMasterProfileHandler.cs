using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Domain;
using BarberBooking.API.Domain.MasterDomain;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Dto.DtoMasterProfile;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterProfile.Commands.Handlers
{
    public class CreateMasterProfileHandler : IRequestHandler<CreateMasterProfileCommand, Result<DtoCreateProfileInfo>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly IMasterProfileRepository _masterProfileRepository;
        private readonly ILogger<CreateMasterProfileHandler> _logger;
        private readonly IEventStoreRepository _eventStoreRepository;
        private readonly IKafkaProducerSalonEvent<MasterCreatedEvent> _kafkaProducerSalonEvent;
        private readonly IRatingCreateMasterService _ratingCreateMaster;
        public CreateMasterProfileHandler(IUnitOfWork unitOfWork, IMapper mapper, ILogger<CreateMasterProfileHandler> logger, IEventStoreRepository eventStoreRepository, IMasterProfileRepository masterProfileRepository, IKafkaProducerSalonEvent<MasterCreatedEvent> kafkaProducerSalonEvent, IRatingCreateMasterService ratingCreateMaster)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
            _eventStoreRepository = eventStoreRepository;
            _masterProfileRepository = masterProfileRepository;
            _kafkaProducerSalonEvent = kafkaProducerSalonEvent;
            _ratingCreateMaster = ratingCreateMaster;
        }
        public async Task<Result<DtoCreateProfileInfo>> Handle(CreateMasterProfileCommand command, CancellationToken cancellationToken)
        {

            var masterProfileByUserId = await _masterProfileRepository.GetMasterProfileByUserId(command.dtoCreateMasterProfile.UserId);
            if(masterProfileByUserId != null)
                return Result.Failure<DtoCreateProfileInfo>("Профиль мастера уже создан");
            var masterProfile = Models.MasterProfile.Create(command.dtoCreateMasterProfile.UserId, command.dtoCreateMasterProfile.SalonId, 
            command.dtoCreateMasterProfile.Bio, command.dtoCreateMasterProfile.Specialization, 
            command.dtoCreateMasterProfile.AvatarUrl);
            var domainCreatedEvent = new MasterCreatedEvent(masterProfile.Id, masterProfile.UserId, masterProfile.SalonId, masterProfile.Bio, masterProfile.Specialization, masterProfile.AvatarUrl);
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.masterProfileRepository.CreateMasterProfile(masterProfile);
                await _eventStoreRepository.SaveEventsAsync(domainCreatedEvent.AggregateId, new List<DomainEvent>{domainCreatedEvent});
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                _logger.LogError(ex.Message);
            }
            await _kafkaProducerSalonEvent.ProduceAsync(domainCreatedEvent, cancellationToken);
            await _ratingCreateMaster.AddRating(masterProfile.Id, cancellationToken);
            var result =  _mapper.Map<DtoCreateProfileInfo>(masterProfile);
            return Result.Success(result);
        }
    }
}