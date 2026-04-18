using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonsAdminContracts;
using BarberBooking.API.Dto.DtoServices;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Services.ServicesQueries.Handller
{
    public class GetServicesBySalonPagedHandler : IRequestHandler<GetServicesBySalonPagedQuery, Result<PagedResult<DtoServicesAdminListItem>>>
    {
        private readonly IServicesRepository _servicesRepository;
        private readonly IMapper _mapper;
        private readonly AdminSalonAccess _adminSalonAccess;

        public GetServicesBySalonPagedHandler(IServicesRepository servicesRepository, IMapper mapper, AdminSalonAccess adminSalonAccess)
        {
            _servicesRepository = servicesRepository;
            _mapper = mapper;
            _adminSalonAccess = adminSalonAccess;
        }

        public async Task<Result<PagedResult<DtoServicesAdminListItem>>> Handle(GetServicesBySalonPagedQuery query, CancellationToken cancellationToken)
        {
            var access = await _adminSalonAccess.RequireSalonAsync(query.salonId, cancellationToken);
            if (access.IsFailure)
                return Result.Failure<PagedResult<DtoServicesAdminListItem>>(access.Error);
            var services = await _servicesRepository.GetServicesBySalonPaged(query.salonId, query.pageParams);
            if (services.Count == 0)
                return Result.Failure<PagedResult<DtoServicesAdminListItem>>("Список услуг пуст");
            var result = _mapper.Map<PagedResult<DtoServicesAdminListItem>>(services);
            return Result.Success(result);
        }
    }
}
