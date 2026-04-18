using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.SalonsAdminContracts;
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
        private readonly AdminSalonAccess _adminSalonAccess;
        public GetSalonAdminStatsHandler(ISalonsRepository salonsRepository, IMapper mapper, AdminSalonAccess adminSalonAccess)
        {
            _salonsRepository = salonsRepository;
            _mapper = mapper;
            _adminSalonAccess = adminSalonAccess;
        }

        public async Task<Result<DtoSalonAdminStats>> Handle(GetSalonAdminStatsQuery query, CancellationToken cancellationToken)
        {
            var access = await _adminSalonAccess.RequireSalonAsync(query.salonId, cancellationToken);
            if (access.IsFailure)
                return Result.Failure<DtoSalonAdminStats>(access.Error);
            var salon = await _salonsRepository.GetSalonStats(query.salonId);
            if (salon == null)
                return Result.Failure<DtoSalonAdminStats>("Салон не найден");
            var dto = _mapper.Map<DtoSalonAdminStats>(salon);
            return Result.Success(dto);
        }
    }
}
