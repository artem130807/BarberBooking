using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterTimeSlotContracts;

namespace BarberBooking.API.Service.TimeSlotService
{
    public class TimeSlotQualifierBookedService : ITimeSlotQualifierBookedService
    {
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly IServicesRepository _servicesRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<TimeSlotQualifierBookedService> _logger;
        public TimeSlotQualifierBookedService(IMasterTimeSlotRepository masterTimeSlotRepository, IServicesRepository servicesRepository, IUnitOfWork unitOfWork, ILogger<TimeSlotQualifierBookedService> logger)
        {
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _servicesRepository = servicesRepository;
            _unitOfWork = unitOfWork;
            _logger = logger;
        }
        public async Task Handle(Guid timeSlotId, DateOnly date)
        {
            var timeSlot = await _masterTimeSlotRepository.GetByIdAsync(timeSlotId);
            var services = await _servicesRepository.GetServicesBySalon(timeSlot.Master.SalonId);
            int count = 0;
            foreach(var service in services)
            {
                var availlableTimeSlots = await _masterTimeSlotRepository.GetAvailableSlotsAsync(timeSlot.MasterId, date, TimeSpan.FromMinutes(service.DurationMinutes));
                if(availlableTimeSlots.Count > 0)
                    count++;
            }
            if(count == 0)
            {
                try
                {
                    _unitOfWork.BeginTransaction();
                    timeSlot.UpdateMasterTimeSlotStatus(Enums.MasterTimeSlotStatus.Booked);
                    _unitOfWork.Commit();
                    _logger.LogInformation("Слот полносью зарезервирован");  
                }catch(Exception ex)
                {
                    _unitOfWork.RollBack();
                    _logger.LogError(ex.Message);
                }
            }
        }
    }
}