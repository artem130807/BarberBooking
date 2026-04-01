using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MessagesContracts;
using BarberBooking.API.Enums;
using BarberBooking.API.Models;

namespace BarberBooking.API.Service.MessageService
{
    public class SendMessageService : ISendMessageService
    {
        private readonly IMessagesRepository _messagesRepository;
        private readonly INotificationService _notificationService;
        private readonly ILogger<SendMessageService> _logger;
        public SendMessageService(IMessagesRepository messagesRepository, ILogger<SendMessageService> logger, INotificationService notificationService)
        {
            _messagesRepository = messagesRepository;
            _logger   = logger;
            _notificationService = notificationService;
        }
        public async Task Send(Messages message)
        {
            var request = Messages.Create(message.Content, message.UserId, message.AppointmentId, message.Audience, message.TypeMessage);
            await _messagesRepository.Add(request.Value);
            await _notificationService.SendAppointmentNotification(message);
            _logger.LogInformation("Успешная отправка сообщения");
        }            
    }
}