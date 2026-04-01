using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Dto.DtoMasterStatistic;
using BarberBooking.API.Enums;
using Microsoft.Extensions.Logging;

namespace BarberBooking.API.Service.Background
{
    public class MasterStatisticHandler : IMasterStatisticHandler
    {
        private readonly IMasterProfileRepository _masterProfileRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly ILogger<MasterStatisticHandler> _logger;

        public MasterStatisticHandler(
            IMasterProfileRepository masterProfileRepository,
            IUnitOfWork unitOfWork,
            IMapper mapper,
            ILogger<MasterStatisticHandler> logger)
        {
            _masterProfileRepository = masterProfileRepository;
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task Handle(CancellationToken cancellationToken)
        {
            var now = DateTime.UtcNow;
            var reportDate = new DateTime(now.Year, now.Month, now.Day, 0, 0, 0, DateTimeKind.Utc).AddDays(-1);

            var masters = await _masterProfileRepository.GetMastersDayStats(
                reportDate.Year,
                reportDate.Month,
                reportDate.Day,
                cancellationToken);

            var masterIdsAlreadyRecorded =
                await _unitOfWork.masterStatisticRepository.GetMasterProfileIdsWithStatisticForDayAsync(
                    reportDate.Year,
                    reportDate.Month,
                    reportDate.Day,
                    cancellationToken);

            var statesDto = masters
                .Where(m => !masterIdsAlreadyRecorded.Contains(m.Id))
                .Select(m => new MasterStatsDto
                {
                    MasterProfileId = m.Id,
                    Rating = m.Rating,
                    RatingCount = m.RatingCount,
                    CreatedAt = reportDate,
                    CompletedAppointmentsCount = m.Appointments.Count(a =>
                        a.Status == AppointmentStatusEnum.Completed),
                    CancelledAppointmentsCount = m.Appointments.Count(a =>
                        a.Status == AppointmentStatusEnum.Cancelled),
                    SumPrice = (double)m.Appointments
                        .Where(a => a.Status == AppointmentStatusEnum.Completed)
                        .Sum(a => a.Service.Price.Value)
                })
                .ToList();

            if (statesDto.Count == 0)
            {
                _logger.LogInformation(
                    "Дневная статистика мастеров за {ReportDate:yyyy-MM-dd}: нечего записывать (все уже есть или нет данных).",
                    reportDate);
                return;
            }

            var states = _mapper.Map<List<Models.MasterStatistic>>(statesDto);
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.masterStatisticRepository.AddRange(states);
                _unitOfWork.Commit();
                _logger.LogInformation(
                    "Дневная статистика мастеров за {ReportDate:yyyy-MM-dd}: записано {Count} мастеров.",
                    reportDate,
                    states.Count);
            }
            catch (Exception ex)
            {
                _unitOfWork.RollBack();
                _logger.LogError(ex, "Ошибка при сохранении дневной статистики мастеров за {ReportDate:yyyy-MM-dd}", reportDate);
            }
        }
    }
}
