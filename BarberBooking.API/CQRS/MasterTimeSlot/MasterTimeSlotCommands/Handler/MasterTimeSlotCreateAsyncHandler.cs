using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using BarberBooking.API.Models;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotCommands.Handler
{
    public class MasterTimeSlotCreateAsyncHandler : IRequestHandler<MasterTimeSlotCreateAsyncCommand, DtoMasterTimeSlotInfo>
    {
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;
        public MasterTimeSlotCreateAsyncHandler(IMapper mapper, IUnitOfWork unitOfWork)
        {
            _mapper = mapper;
            _unitOfWork = unitOfWork;
        }
        public async Task<DtoMasterTimeSlotInfo> Handle(MasterTimeSlotCreateAsyncCommand command, CancellationToken cancellationToken)
        {
            var dtoTimeSlot = _mapper.Map<MasterTimeSlot>(command.dtoCreateMasterTimeSlot);
            var timeSlot = MasterTimeSlot.Create(dtoTimeSlot.MasterId, dtoTimeSlot.ScheduleDate,dtoTimeSlot.StartTime, dtoTimeSlot.EndTime);
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