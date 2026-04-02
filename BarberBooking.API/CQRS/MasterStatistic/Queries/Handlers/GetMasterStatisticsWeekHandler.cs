using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.CQRS.MasterStatistic.Queries;
using BarberBooking.API.Dto.DtoMasterStatistic;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterStatistic.Queries.Handlers
{
    public class GetMasterStatisticsWeekHandler : IRequestHandler<GetMasterStatisticsWeekQuery, Result<DtoMasterStatistic>>
    {
        private readonly IMasterStatisticRepository _masterStatisticRepository;

        public GetMasterStatisticsWeekHandler(IMasterStatisticRepository masterStatisticRepository)
        {
            _masterStatisticRepository = masterStatisticRepository;
        }

        public async Task<Result<DtoMasterStatistic>> Handle(
            GetMasterStatisticsWeekQuery query,
            CancellationToken cancellationToken)
        {
            var statistics = await _masterStatisticRepository.GetMasterStatisticsWeekByMasterProfileId(
                query.masterProfileId,
                query.statisticsParams);
            if (statistics.Count == 0)
            {
                return Result.Success(new DtoMasterStatistic
                {
                    MasterProfileId = query.masterProfileId,
                    Rating = 0,
                    RatingCount = 0,
                    CancelledAppointmentsCount = 0,
                    CompletedAppointmentsCount = 0,
                    SumPrice = 0
                });
            }
            var dto = new DtoMasterStatistic
            {
                MasterProfileId = query.masterProfileId,
                Rating = statistics.Sum(s => s.Rating),
                RatingCount = Convert.ToInt32(statistics.Sum(s => s.RatingCount)),
                CancelledAppointmentsCount = Convert.ToInt32(statistics.Sum(s => s.CancelledAppointmentsCount)),
                CompletedAppointmentsCount = Convert.ToInt32(statistics.Sum(s => s.CompletedAppointmentsCount)),
                SumPrice = statistics.Sum(s => s.SumPrice)
            };
            return Result.Success(dto);
        }
    }
}
