using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Dto;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Models;

namespace BarberBooking.API.Service.UpdateService
{
    public class UpdateAppointmentService : IUpdateAppointmentService
    {
        public async Task UpdateAsync(Appointments appointments, DtoUpdateAppointment? dto)
        {
           var serviceId = dto.ServiceId.HasValue ? dto.ServiceId : appointments.ServiceId;
           appointments.UpdateServiceId(serviceId.Value);
           var startTime = dto.StartTime.HasValue ? dto.StartTime : appointments.StartTime;
           appointments.UpdateStartTime(startTime.Value);
           var endTime = dto.EndTime.HasValue ? dto.EndTime : appointments.EndTime;
           appointments.UpdateEndTime(endTime.Value);
           var notes = !string.IsNullOrWhiteSpace(dto.ClientNotes) ? dto.ClientNotes : appointments.ClientNotes;
           appointments.UpdateClientNotes(notes);
           var status = dto.Status.HasValue ? dto.Status : appointments.Status;
           appointments.UpdateAppointmentStatusEnum(status.Value);
        }
    }
}