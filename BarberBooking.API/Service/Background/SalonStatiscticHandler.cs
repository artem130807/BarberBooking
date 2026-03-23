using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Dto.DtoSalons;

namespace BarberBooking.API.Service.Background
{
    public class SalonStatiscticHandler : ISalonStatiscticHandler
    {
        private readonly ISalonsRepository _salonsRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public SalonStatiscticHandler(ISalonsRepository salonsRepository, IUnitOfWork unitOfWork, IMapper mapper)
        {
            _salonsRepository = salonsRepository;
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }
        public async Task Handle(CancellationToken cancellationToken)
        {
            var now = DateTime.UtcNow;
            var reportMonth = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);

            var salons = await _salonsRepository.GetSalonsMonthStats(reportMonth.Year, reportMonth.Month, cancellationToken);
            var salonIdsAlreadyRecorded =
                await _unitOfWork.salonStatisticRepository.GetSalonIdsWithStatisticForMonthAsync(
                    reportMonth.Year, reportMonth.Month, cancellationToken);

            var statesDto = salons
                .Where(s => !salonIdsAlreadyRecorded.Contains(s.Id))
                .Select(s => new SalonStatsDto
                {
                    SalonId = s.Id,
                    Rating = s.Rating,
                    RatingCount = s.RatingCount,
                    CreatedAt = reportMonth,
                    CompletedAppointmentsCount = s.Appointments.Count(a => a.Status == Enums.AppointmentStatusEnum.Completed),
                    CancelledAppointmentsCount = s.Appointments.Count(a => a.Status == Enums.AppointmentStatusEnum.Cancelled)
                })
                .ToList();

            if (statesDto.Count == 0)
                return;

            var states = _mapper.Map<List<Models.SalonStatistic>>(statesDto);
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.salonStatisticRepository.AddRange(states);
                _unitOfWork.Commit();
            }
            catch (Exception)
            {
                _unitOfWork.RollBack();
            }
        }
    }
}
