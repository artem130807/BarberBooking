using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.MasterServicesContracts;
using BarberBooking.API.CQRS.MasterServices.MasterServicesQueries;
using BarberBooking.API.Dto.DtoServices;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterServices.MasterServicesQueries.Handlers
{
    public class GetMasterServicesForBookingHandler
        : IRequestHandler<GetMasterServicesForBookingQuery, Result<List<DtoServicesInfo>>>
    {
        private readonly IMasterServicesRepository _masterServicesRepository;
        private readonly IMapper _mapper;

        public GetMasterServicesForBookingHandler(
            IMasterServicesRepository masterServicesRepository,
            IMapper mapper)
        {
            _masterServicesRepository = masterServicesRepository;
            _mapper = mapper;
        }

        public async Task<Result<List<DtoServicesInfo>>> Handle(
            GetMasterServicesForBookingQuery query,
            CancellationToken cancellationToken)
        {
            var links = await _masterServicesRepository.GetByMasterProfileIdAsync(query.MasterProfileId);
            var services = links
                .Where(x => x.Service != null && x.Service.IsActive)
                .Select(x => x.Service)
                .ToList();
            var dto = _mapper.Map<List<DtoServicesInfo>>(services);
            return Result.Success(dto);
        }
    }
}
