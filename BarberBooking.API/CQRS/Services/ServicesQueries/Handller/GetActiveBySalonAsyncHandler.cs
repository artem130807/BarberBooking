using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoServices;
using MediatR;

namespace BarberBooking.API.CQRS.ServicesQueries.Handller
{
    public class GetActiveBySalonAsyncHandler : IRequestHandler<GetActiveBySalonAsyncQuery, List<DtoServicesInfo>>
    {
        private readonly IServicesRepository _servicesRepository;
        private readonly IMapper _mapper;
        public GetActiveBySalonAsyncHandler(IServicesRepository servicesRepository, IMapper mapper)
        {
            _servicesRepository = servicesRepository;
            _mapper = mapper;
        }
        public async Task<List<DtoServicesInfo>> Handle(GetActiveBySalonAsyncQuery query, CancellationToken cancellationToken)
        {
            var services = await _servicesRepository.GetActiveBySalonAsync(query.salonId);
            return _mapper.Map<List<DtoServicesInfo>>(services);
        }
    }
}