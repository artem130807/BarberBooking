using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Dto.DtoSalonStatistic;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.SalonStatisctic.Queries.Handlers
{
    public class GetSalonStatisticsMounthHandler : IRequestHandler<GetSalonStatisticsMounthQuery, Result<DtoSalonStatistic>>
    {
        private readonly ISalonStatisticRepository _salonStatisticRepository;
        public GetSalonStatisticsMounthHandler(ISalonStatisticRepository salonStatisticRepository)
        {
            _salonStatisticRepository = salonStatisticRepository;
        }
        public async Task<Result<DtoSalonStatistic>> Handle(GetSalonStatisticsMounthQuery query, CancellationToken cancellationToken)
        {
            var salonStatistics = await _salonStatisticRepository.GetSalonStatisticsMounthBySalonId(query.salonId, query.mounth, query.date);
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
