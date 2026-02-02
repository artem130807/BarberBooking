using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotCommands.Handler
{
    public class MasterTimeSlotUpdateHandler : IRequestHandler<MasterTimeSlotUpdateCommand, DtoMasterTimeSlotInfo>
    {
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IUpdateMasterTimeSlotService _updateMasterTimeSlotService;
        public MasterTimeSlotUpdateHandler(IMasterTimeSlotRepository masterTimeSlotRepository, IMapper mapper, IUnitOfWork unitOfWork, IUpdateMasterTimeSlotService updateMasterTimeSlotService)
        {
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _mapper = mapper;
            _unitOfWork = unitOfWork;
            _updateMasterTimeSlotService = updateMasterTimeSlotService;
        }
        public async Task<DtoMasterTimeSlotInfo> Handle(MasterTimeSlotUpdateCommand command, CancellationToken cancellationToken)
        {
            var timeSlot = await _masterTimeSlotRepository.GetByIdAsync(command.Id);
            if(timeSlot  == null)
                throw new InvalidOperationException("Такого слота нету");
            try
            {
                _unitOfWork.BeginTransaction();
                await _updateMasterTimeSlotService.UpdateAsync(timeSlot, command.dtoUpdateMasterTimeSlot);
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