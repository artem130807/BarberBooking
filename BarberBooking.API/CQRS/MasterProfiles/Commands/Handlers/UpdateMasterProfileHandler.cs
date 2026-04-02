using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Dto.DtoMasterProfile;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterProfile.Commands.Handlers
{
    public class UpdateMasterProfileHandler : IRequestHandler<UpdateMasterProfileCommand, Result<DtoMasterProfileInfo>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IUpdateMasterProfile _updateMasterProfile;
        private readonly IMasterProfileRepository _masterProfileRepository;
        private readonly IUserContext _userContext;
        private readonly ILogger<CreateMasterProfileHandler> _logger;
        private readonly IMapper _mapper;
        public UpdateMasterProfileHandler(IUnitOfWork unitOfWork ,IUpdateMasterProfile updateMasterProfile, IMasterProfileRepository masterProfileRepository, IUserContext userContext, ILogger<CreateMasterProfileHandler> logger, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _updateMasterProfile = updateMasterProfile;
            _masterProfileRepository = masterProfileRepository;
            _userContext = userContext;
            _logger = logger;
            _mapper = mapper;
        }
        public async Task<Result<DtoMasterProfileInfo>> Handle(UpdateMasterProfileCommand command, CancellationToken cancellationToken)
        {
            var self = await _masterProfileRepository.GetMasterProfileByUserId(_userContext.UserId);
            if (self == null || self.Id != command.masterprofileId)
                return Result.Failure<DtoMasterProfileInfo>("Нет доступа");
            var masterProfile = await _masterProfileRepository.GetMasterProfileById(command.masterprofileId);
            if(masterProfile == null)
                return Result.Failure<DtoMasterProfileInfo>("Профиль мастера не найден");
            try
            {
                _unitOfWork.BeginTransaction();
                await _updateMasterProfile.UpdateAsync(masterProfile, command.DtoUpdateMasterProfile);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                _logger.LogError(ex.Message);
                return Result.Failure<DtoMasterProfileInfo>("Не удалось обновить профиль");
            }
            return Result.Success(_mapper.Map<DtoMasterProfileInfo>(masterProfile));
        }
    }
}