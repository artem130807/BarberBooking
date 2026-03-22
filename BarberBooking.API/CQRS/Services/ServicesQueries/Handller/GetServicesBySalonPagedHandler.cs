using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
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

        public GetServicesBySalonPagedHandler(IServicesRepository servicesRepository, IMapper mapper)
        {
            _servicesRepository = servicesRepository;
            _mapper = mapper;
        }

        public async Task<Result<PagedResult<DtoServicesAdminListItem>>> Handle(GetServicesBySalonPagedQuery query, CancellationToken cancellationToken)
        {
            var services = await _servicesRepository.GetServicesBySalonPaged(query.salonId, query.pageParams);
            if (services.Count == 0)
                return Result.Failure<PagedResult<DtoServicesAdminListItem>>("Список услуг пуст");
            var result = _mapper.Map<PagedResult<DtoServicesAdminListItem>>(services);
            return Result.Success(result);
        }
    }
}
