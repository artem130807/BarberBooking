using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.AppointmentContracts;
using BarberBooking.API.Contracts.SalonsContracts;

namespace BarberBooking.API.Service.Background.Handlers
{
    public class AutoAppointmentsCancelledHandler : IAutoAppointmentsCancelledHandler
    {
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly ILogger<AutoAppointmentsCancelledHandler> _logger;
        public AutoAppointmentsCancelledHandler(IAppointmentsRepository appointmentsRepository, ILogger<AutoAppointmentsCancelledHandler> logger)
        {
            _appointmentsRepository = appointmentsRepository;
            _logger = logger;
        }
        public async Task Handle(CancellationToken cancellationToken)
        {
            var appointments = await _appointmentsRepository.GetAppointmentsByDateTo(DateTime.UtcNow);
            _logger.LogInformation($"Количество записей для отмены {appointments.Count}");
            if(appointments.Count != 0)
            {
                foreach(var appointment in appointments)
                {
                    appointment.UpdateStatus(Enums.AppointmentStatusEnum.Cancelled);
                }
                await _appointmentsRepository.SaveChangesAsync();
                _logger.LogInformation("Обновлен статус на Cancelled");
            }
        }
    }
}