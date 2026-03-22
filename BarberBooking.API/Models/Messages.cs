using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Models
{
    public class Messages
    {
        public Guid Id {get; private set;}
        public string? Content {get; private set;}
        public Guid UserId {get; private set;}
        public Guid? AppointmentId {get; private set;}
        public Users User {get; private set;}
        public Appointments? Appointment {get; private set;}
        public bool IsVisible {get; private set;} 
        public DateTime CreatedAt {get; private set;}
        public static Result<Messages> Create(string content, Guid userId, Guid? appointmentId)
        {
            if (string.IsNullOrWhiteSpace(content))
                return Result.Failure<Messages>("Содержание сообщения не может быть пустым");

            if (content.Length > 1000)
                return Result.Failure<Messages>("Сообщение не может превышать 1000 символов");

            var message = new Messages
            {
                Id = Guid.NewGuid(),
                Content = content,
                UserId = userId,
                AppointmentId = appointmentId,
                IsVisible = false,
                CreatedAt = DateTime.UtcNow
            };
            return message;
        }
        public void UpdateVisible(bool isVisible) => IsVisible = isVisible;
    }
}