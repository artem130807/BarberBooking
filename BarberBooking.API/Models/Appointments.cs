using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Enums;

namespace BarberBooking.API.Models
{
    public class Appointments
    {
        public Guid Id { get; private set; } 
        public Guid SalonId { get; private set; }
        public Guid ClientId {get; private set;}
        public Guid MasterId { get; private set; }
        public Guid ServiceId { get; private set; }
        public Guid TimeSlotId { get; private set; }
        public string? ClientNotes {get; private set;}
        public AppointmentStatusEnum Status {get; private set;} = AppointmentStatusEnum.Confirmed;
        public TimeOnly StartTime { get; private set; }
        public TimeOnly EndTime { get; private set; } 
        public DateTime AppointmentDate {get; private set;} 
        public DateTime CreatedAt { get; private set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; private set; } = DateTime.UtcNow;
        public Salons Salon { get; private set; }
        public Users Client {get; private set;}
        public MasterProfile Master { get; private set; } 
        public  Services Service { get; private set; }
        public MasterTimeSlot TimeSlot { get; private set; }
        public ICollection<Messages>? Messages {get; private set;}
        private Appointments()
        {
            Messages = new List<Messages>();
        }

        public static Appointments Create(Guid salonId, Guid masterId, Guid clientId , Guid serviceId, Guid timeSlotId,  TimeOnly startTime, string clientNotes, TimeOnly endTime, DateTime appointmentDate)
        {
            var appointment = new Appointments
            {
                Id = Guid.NewGuid(),
                SalonId = salonId,
                MasterId = masterId,
                ClientId = clientId,
                ServiceId = serviceId,
                TimeSlotId = timeSlotId,
                ClientNotes = clientNotes,
                Status = AppointmentStatusEnum.Confirmed,
                StartTime = startTime,
                EndTime = endTime,
                AppointmentDate = appointmentDate,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
            };
            return appointment;
        }
        public static Appointments Create(Appointments appointmentEntity)
        {
            var appointment = new Appointments
            {
                Id = Guid.NewGuid(),
                SalonId = appointmentEntity.SalonId,
                MasterId = appointmentEntity.MasterId,
                ClientId = appointmentEntity.ClientId,
                ServiceId = appointmentEntity.ServiceId,
                TimeSlotId = appointmentEntity.TimeSlotId,
                ClientNotes = appointmentEntity.ClientNotes,
                StartTime = appointmentEntity.StartTime,
                EndTime = appointmentEntity.EndTime,
                AppointmentDate = appointmentEntity.AppointmentDate,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
            };
            return appointment;
        }
        public void UpdateServiceId(Guid serviceId)
        {
            ServiceId = serviceId;
            UpdatedAt = DateTime.UtcNow;
        }
        public void UpdateStartTime(TimeOnly startTime)
        {
            StartTime = startTime;
            UpdatedAt = DateTime.UtcNow;
        }
            
        public void UpdateEndTime(TimeOnly endTime)
        {
            EndTime = endTime;
            UpdatedAt = DateTime.UtcNow;
        } 
        public void UpdateClientNotes(string clientNotes)
        {
            ClientNotes = clientNotes;
            UpdatedAt = DateTime.UtcNow;
        }
        public void UpdateAppointmentStatusEnum(AppointmentStatusEnum status)
        {
            Status = status;
            UpdatedAt = DateTime.UtcNow;
        }
        
    }
}