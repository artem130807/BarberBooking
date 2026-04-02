using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MessagesContracts;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using CSharpFunctionalExtensions;
using MediatR;
using Org.BouncyCastle.Asn1.Cms;

namespace BarberBooking.API.CQRS.MasterTimeSlotCommands.Handler
{
    public class MasterTimeSlotDeleteAsyncHandler : IRequestHandler<MasterTimeSlotDeleteAsyncCommand, Result<DtoMasterTimeSlotInfo>>
    {
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly ISendMessageService _messageService;
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IAppointmentsRepository _appointmentsRepository;
        public MasterTimeSlotDeleteAsyncHandler(IMasterTimeSlotRepository masterTimeSlotRepository, IMapper mapper, IUnitOfWork unitOfWork, ISendMessageService messageService, IAppointmentsRepository appointmentsRepository)
        {
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _mapper = mapper;
            _unitOfWork = unitOfWork;
            _messageService = messageService;
            _appointmentsRepository = appointmentsRepository;
        }
        public async Task<Result<DtoMasterTimeSlotInfo>> Handle(MasterTimeSlotDeleteAsyncCommand command, CancellationToken cancellationToken)
        {
            var timeSlot = await _masterTimeSlotRepository.GetByIdAsync(command.Id);
            if(timeSlot == null)
                return Result.Failure<DtoMasterTimeSlotInfo>("Такого слота не существует");
            try
            {
                _unitOfWork.BeginTransaction();
                timeSlot.UpdateMasterTimeSlotStatus(Enums.MasterTimeSlotStatus.Cancelled); 

                if(timeSlot.Appointments.Count != 0)
                    await _unitOfWork.appointmentsRepository.StatusUpdateRange(timeSlot.Id, Enums.AppointmentStatusEnum.Cancelled);
                _unitOfWork.Commit();

            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                throw new InvalidOperationException(ex.Message);
            }
            var appointments = await _appointmentsRepository.GetAppointmentsByTimeSlotId(timeSlot.Id);
            foreach(var appointment in appointments)
            {
                var message = Models.Messages.Create($"Запись на {appointment.AppointmentDate}, отменена", appointment.ClientId, appointment.Id, 
                Enums.MessageAudience.User, Enums.TypeMessage.CancelledAppointment);
                await _messageService.Send(message.Value);
            }
            return _mapper.Map<DtoMasterTimeSlotInfo>(timeSlot);
        }
    }
}