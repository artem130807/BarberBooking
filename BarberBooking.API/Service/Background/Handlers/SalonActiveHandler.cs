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
            var nowDate = DateOnly.FromDateTime(DateTime.Now);
            var nowTime = TimeOnly.FromDateTime(DateTime.Now);

            foreach(var salon in salons)
            {
                try
                {
                    var timeSlots = await _masterTimeSlotRepository.GetTimeSlotsInSalon(salon.Id, nowDate);
                    if(timeSlots == null || !timeSlots.Any())
                    {
                        _unitOfWork.BeginTransaction();
                        if (salon.OpeningTime.HasValue && salon.ClosingTime.HasValue)
                        {
                            var open = salon.OpeningTime.Value;
                            var close = salon.ClosingTime.Value;
                            var active = nowTime >= open && nowTime <= close;
                            salon.UpdateIsActive(active);
                        }
                        else
                        {
                            salon.UpdateIsActive(false);
                        }
                        _unitOfWork.Commit();
                        _logger.LogInformation($"Салон {salon.Name}: нет слотов на сегодня, IsActive={salon.IsActive}");
                        continue;
                    }

                    var minTime = timeSlots.Min(x => x.StartTime);
                    var maxTime = timeSlots.Max(x => x.EndTime);

                    _unitOfWork.BeginTransaction();
                    var withinHours = nowTime >= minTime && nowTime <= maxTime;
                    salon.UpdateIsActive(withinHours);
                    salon.UpdateOpeningTime(minTime);
                    salon.UpdateClosingTime(maxTime);
                    _unitOfWork.Commit();
                    _logger.LogInformation($"Салон {salon.Name}: время {minTime:HH:mm}-{maxTime:HH:mm}, активен: {salon.IsActive}");
                }catch(Exception ex)
                {
                    _unitOfWork.RollBack();
                    _logger.LogError(ex.Message);
                }
            }
            
        }
    }
}
