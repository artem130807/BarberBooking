using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
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
        private readonly IServicesRepository _servicesRepository;
        public UpdateAppointmentService(IServicesRepository servicesRepository)
        {
            _servicesRepository = servicesRepository;
        }
        public async Task UpdateAsync(Appointments appointments, DtoUpdateAppointment? dto)
        {
           var serviceId = dto.ServiceId.HasValue ? dto.ServiceId : appointments.ServiceId;
           appointments.UpdateServiceId(serviceId.Value);
           var notes = !string.IsNullOrWhiteSpace(dto.ClientNotes) ? dto.ClientNotes : appointments.ClientNotes;
           appointments.UpdateClientNotes(notes);
           var status = dto.Status.HasValue ? dto.Status : appointments.Status;
           appointments.UpdateAppointmentStatusEnum(status.Value);
           await UpdateService(appointments, dto);
           await UpdateStartTime(appointments, dto);
        }
        private async Task UpdateService(Appointments appointments, DtoUpdateAppointment? dto)
        {
            var serviceId = dto.ServiceId.HasValue ? dto.ServiceId : appointments.ServiceId;
            if(dto.ServiceId.HasValue)
            {
                var service = await _servicesRepository.GetByIdAsync(serviceId.Value);
                if(service != null)
                {
                    var serviceDuration = TimeSpan.FromMinutes(service.DurationMinutes);
                    var endTime = appointments.StartTime.Add(serviceDuration);
                    appointments.UpdateEndTime(endTime);
                }
            }
            appointments.UpdateServiceId(serviceId.Value);
        }
        private async Task UpdateStartTime(Appointments appointments, DtoUpdateAppointment? dto)
        {
            var startTime = dto.StartTime.HasValue ? dto.StartTime : appointments.StartTime;
            appointments.UpdateStartTime(startTime.Value);
            if (dto.StartTime.HasValue)
            {
                var service = await _servicesRepository.GetByIdAsync(appointments.ServiceId);
                var serviceDuration = TimeSpan.FromMinutes(service.DurationMinutes);
                var endTime = appointments.StartTime.Add(serviceDuration);
                appointments.UpdateEndTime(endTime);
            }  
        }
    }
}