using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotCommands.Handler
{
    public class MasterTimeSlotDeleteAsyncHandler : IRequestHandler<MasterTimeSlotDeleteAsyncCommand, DtoMasterTimeSlotInfo>
    {
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;
        public MasterTimeSlotDeleteAsyncHandler(IMasterTimeSlotRepository masterTimeSlotRepository, IMapper mapper, IUnitOfWork unitOfWork)
        {
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _mapper = mapper;
            _unitOfWork = unitOfWork;
        }
        public async Task<DtoMasterTimeSlotInfo> Handle(MasterTimeSlotDeleteAsyncCommand command, CancellationToken cancellationToken)
        {
            var timeSlot = await _masterTimeSlotRepository.GetByIdAsync(command.Id);
            if(timeSlot == null)
                throw new InvalidOperationException("Такого слота не существует");
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.masterTimeSlotRepository.DeleteAsync(command.Id);
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