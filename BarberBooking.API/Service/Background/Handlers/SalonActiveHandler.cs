using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Models;
using MediatR;

namespace BarberBooking.API.Service.Background
{
    public class SalonActiveHandler:ISalonActiveHandler
    {
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ISalonsRepository _salonsRepository;
        private readonly ILogger<SalonActiveHandler> _logger;
        public SalonActiveHandler(IMasterTimeSlotRepository masterTimeSlotRepository, IUnitOfWork unitOfWork, ISalonsRepository salonsRepository, ILogger<SalonActiveHandler> logger)
        {
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _unitOfWork = unitOfWork;
            _salonsRepository = salonsRepository;
            _logger = logger;
        }

        public async Task Handle(CancellationToken cancellationToken)
        {
            var salons = await _salonsRepository.GetSalons();
            foreach(var salon in salons)
            {
                try
                {
                    var timeSlots = await _masterTimeSlotRepository.GetTimeSlotsInSalon(salon.Id, DateOnly.FromDateTime(DateTime.Now));
                    if(timeSlots == null | !timeSlots.Any())
                    {
                        _unitOfWork.BeginTransaction();
                        salon.UpdateOpeningTime(null);
                        salon.UpdateClosingTime(null);
                        salon.UpdateIsActive(false);
                        _unitOfWork.Commit();
                        _logger.LogInformation($"Салон {salon.Name}: нет слотов на сегодня, установлен неактивным");
                        continue;
                    }
                    if(timeSlots != null)
                    {
                        var minTime = timeSlots.Min(x => x.StartTime);
                        var maxTime = timeSlots.Max(x => x.EndTime);
                    
                        _unitOfWork.BeginTransaction();
                        if(DateTime.Now.Hour >= minTime.Hour || DateTime.Now.Hour <= maxTime.Hour)
                        {
                            salon.UpdateIsActive(true);
                        }
                        else
                        {
                            salon.UpdateIsActive(false);
                        }
                        salon.UpdateOpeningTime(minTime);
                        salon.UpdateClosingTime(maxTime);
                        _unitOfWork.Commit();
                        _logger.LogInformation($"Салон {salon.Name}: время {minTime:HH:mm}-{maxTime:HH:mm}, активен: {salon.IsActive}");
                    }
                }catch(Exception ex)
                {
                    _unitOfWork.RollBack();
                    _logger.LogError(ex.Message);
                }
            }
            
        }
    }
}