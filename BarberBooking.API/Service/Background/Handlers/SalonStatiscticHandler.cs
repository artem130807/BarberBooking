using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Dto.DtoSalons;
using Microsoft.Extensions.Logging;

namespace BarberBooking.API.Service.Background
{
    public class SalonStatiscticHandler : ISalonStatiscticHandler
    {
        private readonly ISalonsRepository _salonsRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly ILogger<SalonStatiscticHandler> _logger;

        public SalonStatiscticHandler(
            ISalonsRepository salonsRepository,
            IUnitOfWork unitOfWork,
            IMapper mapper,
            ILogger<SalonStatiscticHandler> logger)
        {
            _salonsRepository = salonsRepository;
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task Handle(CancellationToken cancellationToken)
        {
            var now = DateTime.UtcNow;
            var reportDate = new DateTime(now.Year, now.Month, now.Day, 0, 0, 0, DateTimeKind.Utc).AddDays(-1);

            var salons = await _salonsRepository.GetSalonsDayStats(
                reportDate.Year,
                reportDate.Month,
                reportDate.Day,
                cancellationToken);

            var salonIdsAlreadyRecorded =
                await _unitOfWork.salonStatisticRepository.GetSalonIdsWithStatisticForDayAsync(
                    reportDate.Year,
                    reportDate.Month,
                    reportDate.Day,
                    cancellationToken);

            var statesDto = salons
                .Where(s => !salonIdsAlreadyRecorded.Contains(s.Id))
                .Select(s => new SalonStatsDto
                {
                    SalonId = s.Id,
                    Rating = s.Rating,
                    RatingCount = s.RatingCount,
                    CreatedAt = reportDate,
                    CompletedAppointmentsCount = s.Appointments.Count(a =>
                        a.Status == Enums.AppointmentStatusEnum.Completed),
                    CancelledAppointmentsCount = s.Appointments.Count(a =>
                        a.Status == Enums.AppointmentStatusEnum.Cancelled),
                    SumPrice = s.Appointments.Where(a => 
                        a.Status == Enums.AppointmentStatusEnum.Completed)
                        .Sum(a => a.Service.Price.Value)
                })
                .ToList();

            if (statesDto.Count == 0)
            {
                _logger.LogInformation(
                    "Дневная статистика салонов за {ReportDate:yyyy-MM-dd}: нечего записывать (все уже есть или нет данных).",
                    reportDate);
                return;
            }

            var states = _mapper.Map<List<Models.SalonStatistic>>(statesDto);
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.salonStatisticRepository.AddRange(states);
                _unitOfWork.Commit();
                _logger.LogInformation(
                    "Дневная статистика салонов за {ReportDate:yyyy-MM-dd}: записано {Count} салонов.",
                    reportDate,
                    states.Count);
            }
            catch (Exception ex)
            {
                _unitOfWork.RollBack();
                _logger.LogError(ex, "Ошибка при сохранении дневной статистики салонов за {ReportDate:yyyy-MM-dd}", reportDate);
            }
        }
    }
}
