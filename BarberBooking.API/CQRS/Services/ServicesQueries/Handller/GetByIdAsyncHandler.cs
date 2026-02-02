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
    public class GetByIdAsyncHandler : IRequestHandler<GetByIdAsyncQuery, DtoServicesInfo>
    {
        private readonly IServicesRepository _servicesRepository;
        private readonly IMapper _mapper;
        public GetByIdAsyncHandler(IServicesRepository servicesRepository, IMapper mapper)
        {
            _servicesRepository = servicesRepository;
            _mapper = mapper;
        }
        public async Task<DtoServicesInfo> Handle(GetByIdAsyncQuery query, CancellationToken cancellationToken)
        {
            var service = await _servicesRepository.GetByIdAsync(query.id);
            return _mapper.Map<DtoServicesInfo>(service);
        }
    }
}