using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoMasterProfile;
using MediatR;

namespace BarberBooking.API.CQRS.MasterProfile.Commands.Handlers
{
    public class CreateMasterProfileHandler : IRequestHandler<CreateMasterProfileCommand, DtoCreateProfileInfo>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly ILogger<CreateMasterProfileHandler> _logger;
        public CreateMasterProfileHandler(IUnitOfWork unitOfWork, IMapper mapper, ILogger<CreateMasterProfileHandler> logger)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
        }
        public async Task<DtoCreateProfileInfo> Handle(CreateMasterProfileCommand command, CancellationToken cancellationToken)
        {
            var masterProfile = _mapper.Map<Models.MasterProfile>(command.dtoCreateMasterProfile);
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.masterProfileRepository.CreateMasterProfile(masterProfile);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                _logger.LogError(ex.Message);
            }
            return _mapper.Map<DtoCreateProfileInfo>(masterProfile);
        }
    }
}