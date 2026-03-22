using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Dto.DtoSalons;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Salon.Queries.Handlers
{
    public class GetSalonAdminStatsHandler : IRequestHandler<GetSalonAdminStatsQuery, Result<DtoSalonAdminStats>>
    {
        private readonly ISalonsRepository _salonsRepository;
        private readonly IMapper _mapper;

        public GetSalonAdminStatsHandler(ISalonsRepository salonsRepository, IMapper mapper)
        {
            _salonsRepository = salonsRepository;
            _mapper = mapper;
        }

        public async Task<Result<DtoSalonAdminStats>> Handle(GetSalonAdminStatsQuery query, CancellationToken cancellationToken)
        {
            var salon = await _salonsRepository.GetSalonStats(query.salonId);
            if (salon == null)
                return Result.Failure<DtoSalonAdminStats>("Салон не найден");
            var dto = _mapper.Map<DtoSalonAdminStats>(salon);
            return Result.Success(dto);
        }
    }
}
