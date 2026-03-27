using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Domain;
using BarberBooking.API.Domain.MasterDomain;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Enums;
using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.Extensions.Logging;

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
        private readonly IUserRolesRepository _userRolesRepository;

        public CreateMasterProfileHandler(
            IUnitOfWork unitOfWork,
            IMapper mapper,
            ILogger<CreateMasterProfileHandler> logger,
            IEventStoreRepository eventStoreRepository,
            IMasterProfileRepository masterProfileRepository,
            IKafkaProducerSalonEvent<MasterCreatedEvent> kafkaProducerSalonEvent,
            IRatingCreateMasterService ratingCreateMaster,
            IUserRolesRepository userRolesRepository)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
            _eventStoreRepository = eventStoreRepository;
            _masterProfileRepository = masterProfileRepository;
            _kafkaProducerSalonEvent = kafkaProducerSalonEvent;
            _ratingCreateMaster = ratingCreateMaster;
            _userRolesRepository = userRolesRepository;
        }

        public async Task<Result<DtoCreateProfileInfo>> Handle(CreateMasterProfileCommand command, CancellationToken cancellationToken)
        {
            var dto = command.dtoCreateMasterProfile;
            var email = dto.EmailUser?.Trim();
            if (string.IsNullOrWhiteSpace(email))
                return Result.Failure<DtoCreateProfileInfo>("Укажите email пользователя.");

            var user = await _unitOfWork.userRepository.GetUserByEmail(email);
            if (user == null)
                return Result.Failure<DtoCreateProfileInfo>("Пользователь с таким email не найден.");

            var salon = await _unitOfWork.salonsRepository.GetSalonById(dto.SalonId);
            if (salon == null)
                return Result.Failure<DtoCreateProfileInfo>("Салон не найден.");

            var existing = await _masterProfileRepository.GetMasterProfileByUserId(user.Id);
            if (existing != null)
                return Result.Failure<DtoCreateProfileInfo>("Профиль мастера уже создан.");

            var masterProfile = Models.MasterProfile.Create(
                user.Id,
                dto.SalonId,
                dto.Bio,
                dto.Specialization,
                dto.AvatarUrl);

            var domainCreatedEvent = new MasterCreatedEvent(
                masterProfile.Id,
                masterProfile.UserId,
                masterProfile.SalonId,
                masterProfile.Bio,
                masterProfile.Specialization,
                masterProfile.AvatarUrl);

            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.masterProfileRepository.CreateMasterProfile(masterProfile);
                await _userRolesRepository.AddUserRoleAsync(masterProfile.UserId, (int)RolesEnum.Master);
                await _eventStoreRepository.SaveEventsAsync(domainCreatedEvent.AggregateId, new List<DomainEvent> { domainCreatedEvent });
                _unitOfWork.Commit();
            }
            catch (Exception ex)
            {
                _unitOfWork.RollBack();
                _logger.LogError(ex, "CreateMasterProfile");
                return Result.Failure<DtoCreateProfileInfo>("Не удалось создать профиль мастера.");
            }

            await _ratingCreateMaster.AddRating(masterProfile.Id, cancellationToken);
            var result = _mapper.Map<DtoCreateProfileInfo>(masterProfile);
            return Result.Success(result);
        }
    }
}
