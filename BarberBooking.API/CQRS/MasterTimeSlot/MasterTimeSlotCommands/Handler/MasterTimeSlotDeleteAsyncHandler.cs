using System;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.MessagesContracts;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using BarberBooking.API.Helpers;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotCommands.Handler
{
    public class MasterTimeSlotDeleteAsyncHandler : IRequestHandler<MasterTimeSlotDeleteAsyncCommand, Result<DtoMasterTimeSlotInfo>>
    {
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly ISendMessageService _messageService;
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;

        public MasterTimeSlotDeleteAsyncHandler(
            IMasterTimeSlotRepository masterTimeSlotRepository,
            IMapper mapper,
            IUnitOfWork unitOfWork,
            ISendMessageService messageService,
            IAppointmentsRepository appointmentsRepository,
            IUserContext userContext,
            IMasterProfileRepository masterProfileRepository)
        {
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _mapper = mapper;
            _unitOfWork = unitOfWork;
            _messageService = messageService;
            _appointmentsRepository = appointmentsRepository;
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
        }

        public async Task<Result<DtoMasterTimeSlotInfo>> Handle(MasterTimeSlotDeleteAsyncCommand command, CancellationToken cancellationToken)
        {
            var master = await _masterProfileRepository.GetMasterProfileByUserId(_userContext.UserId);
            if (master == null)
                return Result.Failure<DtoMasterTimeSlotInfo>("Доступно только мастеру");

            var timeSlot = await _masterTimeSlotRepository.GetByIdAsync(command.Id);
            if (timeSlot == null)
                return Result.Failure<DtoMasterTimeSlotInfo>("Такого слота не существует");
            if (timeSlot.MasterId != master.Id)
                return Result.Failure<DtoMasterTimeSlotInfo>("Нет доступа");

            var appointments = await _appointmentsRepository.GetAppointmentsByTimeSlotId(timeSlot.Id);

            try
            {
                _unitOfWork.BeginTransaction();
                timeSlot.UpdateMasterTimeSlotStatus(Enums.MasterTimeSlotStatus.Cancelled);
                if (appointments.Count != 0)
                    await _unitOfWork.appointmentsRepository.StatusUpdateRange(timeSlot.Id, Enums.AppointmentStatusEnum.Cancelled);
                _unitOfWork.Commit();
            }
            catch (Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<DtoMasterTimeSlotInfo>(ex.Message);
            }

            foreach (var appointment in appointments)
            {
                var message = Models.Messages.Create($"Запись на {AppointmentMessageFormatting.FormatForMessage(appointment.AppointmentDate)}, отменена", appointment.ClientId.Value, appointment.Id,
                    Enums.MessageAudience.User, Enums.TypeMessage.CancelledAppointment);
                await _messageService.Send(message.Value);
            }

            var result = _mapper.Map<DtoMasterTimeSlotInfo>(timeSlot);
            return Result.Success(result);
        }
    }
}
