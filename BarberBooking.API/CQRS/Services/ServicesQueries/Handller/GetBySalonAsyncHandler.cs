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
    public class GetBySalonAsyncHandler : IRequestHandler<GetBySalonAsyncQuery, List<DtoServicesInfo>>
    {
        private readonly IServicesRepository _servicesRepository;
        private readonly IMapper _mapper;
        public GetBySalonAsyncHandler(IServicesRepository servicesRepository, IMapper mapper)
        {
            _servicesRepository = servicesRepository;
            _mapper = mapper;
        }
        public async Task<List<DtoServicesInfo>> Handle(GetBySalonAsyncQuery query, CancellationToken cancellationToken)
        {
            var services = await _servicesRepository.GetBySalonAsync(query.salonId);
            return _mapper.Map<List<DtoServicesInfo>>(services);
        }
    }
}