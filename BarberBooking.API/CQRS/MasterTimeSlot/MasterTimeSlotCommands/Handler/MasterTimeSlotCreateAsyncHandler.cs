using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using BarberBooking.API.Models;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotCommands.Handler
{
    public class MasterTimeSlotCreateAsyncHandler : IRequestHandler<MasterTimeSlotCreateAsyncCommand, DtoMasterTimeSlotInfo>
    {
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;
        public MasterTimeSlotCreateAsyncHandler(IMapper mapper, IUnitOfWork unitOfWork, IUserContext userContext, IMasterProfileRepository masterProfileRepository)
        {
            _mapper = mapper;
            _unitOfWork = unitOfWork;
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
        }
        public async Task<DtoMasterTimeSlotInfo> Handle(MasterTimeSlotCreateAsyncCommand command, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var masterProfile = await _masterProfileRepository.GetMasterProfileByUserId(userId);
            var timeSlot = MasterTimeSlot.Create(masterProfile.Id, command.dtoCreateMasterTimeSlot.ScheduleDate, 
            command.dtoCreateMasterTimeSlot.StartTime, command.dtoCreateMasterTimeSlot.EndTime);
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.masterTimeSlotRepository.CreateAsync(timeSlot);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                throw new InvalidOperationException(ex.Message);
            }
            return _mapper.Map<DtoMasterTimeSlotInfo>(timeSlot);
        }
    }
}