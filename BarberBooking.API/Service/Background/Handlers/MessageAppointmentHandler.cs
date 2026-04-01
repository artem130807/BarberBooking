using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MessagesContracts;
using BarberBooking.API.Models;

namespace BarberBooking.API.Service.Background
{
    public class MessageAppointmentHandler : IMessageAppointmentHandler
    {
        private static readonly TimeSpan ReminderTolerance = TimeSpan.FromMinutes(1);

        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMessagesRepository _messagesRepository;
        private readonly ILogger<MessageAppointmentHandler> _logger;
        private readonly ISendMessageService _sendMessageService;

        public MessageAppointmentHandler(
            IAppointmentsRepository appointmentsRepository,
            IUnitOfWork unitOfWork,
            IMessagesRepository messagesRepository,
            ILogger<MessageAppointmentHandler> logger,
            ISendMessageService sendMessageService)
        {
            _appointmentsRepository = appointmentsRepository;
            _unitOfWork = unitOfWork;
            _messagesRepository = messagesRepository;
            _logger = logger;
            _sendMessageService = sendMessageService;
        }

        public async Task Handle(CancellationToken cancellationToken)
        {
            var now = DateTime.Now;
            var upperBound = now.AddHours(24).AddMinutes(1);

            var appointments = await _appointmentsRepository
                .GetConfirmedAppointmentsInRange(now, upperBound);

            foreach (var appointment in appointments)
            {
                if (cancellationToken.IsCancellationRequested)
                    break;

                var remaining = appointment.AppointmentDate - now;

                await TryCreateReminderAsync(appointment, remaining, 24, cancellationToken);
                await TryCreateReminderAsync(appointment, remaining, 3, cancellationToken);
                await TryCreateReminderAsync(appointment, remaining, 1, cancellationToken);
            }
        }

        private async Task TryCreateReminderAsync(
            Appointments appointment,
            TimeSpan remaining,
            int reminderHours,
            CancellationToken cancellationToken)
        {
            var target = TimeSpan.FromHours(reminderHours);
            if (!IsReminderWindow(remaining, target))
                return;

            var content = BuildReminderContent(reminderHours);
            var existingMessages = await _messagesRepository.GetMessagesByAppointmentId(appointment.Id);
            var alreadyExists = existingMessages.Any(m =>
                string.Equals(m.Content, content, StringComparison.OrdinalIgnoreCase));

            if (alreadyExists)
                return;

            var messageResult = Messages.Create(content, appointment.ClientId, appointment.Id, Enums.MessageAudience.User, Enums.TypeMessage.Reminder);
            if (messageResult.IsFailure)
            {
                _logger.LogWarning(
                    "Не удалось создать reminder для AppointmentId={AppointmentId}. Причина: {Reason}",
                    appointment.Id,
                    messageResult.Error);
                return;
            }

            try
            {
                _unitOfWork.BeginTransaction();
                await _sendMessageService.Send(messageResult.Value);
                _unitOfWork.Commit();

                _logger.LogInformation(
                    "Создано сообщение-напоминание для AppointmentId={AppointmentId}, UserId={UserId}, Reminder={ReminderHours}h",
                    appointment.Id,
                    appointment.ClientId,
                    reminderHours);
            }
            catch (Exception ex)
            {
                _unitOfWork.RollBack();
                _logger.LogError(
                    ex,
                    "Ошибка создания сообщения-напоминания для AppointmentId={AppointmentId}",
                    appointment.Id);
            }
            
        }

        private static bool IsReminderWindow(TimeSpan remaining, TimeSpan target)
        {
            return remaining <= target && remaining > target - ReminderTolerance;
        }

        private static string BuildReminderContent(int reminderHours)
        {
            return reminderHours switch
            {
                24 => "Напоминание: до вашей записи осталось 24 часа.",
                3 => "Напоминание: до вашей записи осталось 3 часа.",
                1 => "Напоминание: до вашей записи остался 1 час.",
                _ => "Напоминание о предстоящей записи.",
            };
        }
    }
}
