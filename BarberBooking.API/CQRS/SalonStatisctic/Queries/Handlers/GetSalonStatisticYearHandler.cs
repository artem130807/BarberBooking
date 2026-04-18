using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.SalonsAdminContracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Dto.DtoSalonStatistic;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.SalonStatisctic.Queries.Handlers
{
    public class GetSalonStatisticYearHandler : IRequestHandler<GetSalonStatisticYearQuery, Result<DtoSalonStatistic>>
    {
        private readonly ISalonStatisticRepository _salonStatisticRepository;
        private readonly AdminSalonAccess _adminSalonAccess;
        public GetSalonStatisticYearHandler(ISalonStatisticRepository salonStatisticRepository, AdminSalonAccess adminSalonAccess)
        {
            _salonStatisticRepository = salonStatisticRepository;
            _adminSalonAccess = adminSalonAccess;
        }
        public async Task<Result<DtoSalonStatistic>> Handle(GetSalonStatisticYearQuery query, CancellationToken cancellationToken)
        {
            var access = await _adminSalonAccess.RequireSalonAsync(query.salonId, cancellationToken);
            if (access.IsFailure)
                return Result.Failure<DtoSalonStatistic>(access.Error);
            var salonStatistics = await _salonStatisticRepository.GetSalonStatisticsYearBySalonId(query.salonId, query.date);
            if (salonStatistics.Count == 0)
                return Result.Failure<DtoSalonStatistic>("Список пуст");
            var dto = new DtoSalonStatistic
            {
                SalonId = query.salonId,
                Rating = salonStatistics.Sum(s => s.Rating),
                RatingCount = Convert.ToInt32(salonStatistics.Sum(s => s.RatingCount)),
                CancelledAppointmentsCount = Convert.ToInt32(salonStatistics.Sum(s => s.CancelledAppointmentsCount)),
                CompletedAppointmentsCount = Convert.ToInt32(salonStatistics.Sum(s => s.CompletedAppointmentsCount)),
                SumPrice = salonStatistics.Sum(s => s.SumPrice)
            };
            return Result.Success(dto);
        }
    }
}
