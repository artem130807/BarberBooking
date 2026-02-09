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
        private readonly ILogger<CreateMasterProfileHandler> _logger;
        private readonly IMapper _mapper;
        public UpdateMasterProfileHandler(IUnitOfWork unitOfWork ,IUpdateMasterProfile updateMasterProfile, IMasterProfileRepository masterProfileRepository, ILogger<CreateMasterProfileHandler> logger, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _updateMasterProfile = updateMasterProfile;
            _masterProfileRepository = masterProfileRepository;
            _logger = logger;
            _mapper = mapper;
        }
        public async Task<Result<DtoMasterProfileInfo>> Handle(UpdateMasterProfileCommand command, CancellationToken cancellationToken)
        {
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
            }
            return _mapper.Map<DtoMasterProfileInfo>(masterProfile);
        }
    }
}