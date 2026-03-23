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
    public class GetTopServicesInSalonHandler : IRequestHandler<GetTopServicesInSalonQuery, Result<PagedResult<DtoServicesSearchResult>>>
    {
        private readonly IServicesRepository _servicesRepository;
        private readonly IMapper _mapper;

        public GetTopServicesInSalonHandler(IServicesRepository servicesRepository, IMapper mapper)
        {
            _servicesRepository = servicesRepository;
            _mapper = mapper;
        }

        public async Task<Result<PagedResult<DtoServicesSearchResult>>> Handle(GetTopServicesInSalonQuery query, CancellationToken cancellationToken)
        {
            var services = await _servicesRepository.GetTopServices(query.salonId, query.pageParams);
            var result = _mapper.Map<PagedResult<DtoServicesSearchResult>>(services);
            return Result.Success(result);
        }
    }
}
