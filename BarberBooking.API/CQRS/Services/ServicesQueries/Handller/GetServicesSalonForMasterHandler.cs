using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Dto.DtoServices;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Services.ServicesQueries.Handller
{
    public class GetServicesSalonForMasterHandler : IRequestHandler<GetServicesSalonForMasterQuery, Result<List<DtoServicesInfo>>>
    {
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;
        private readonly IServicesRepository _servicesRepository;
        private readonly IMapper _mapper;
        public GetServicesSalonForMasterHandler(IUserContext userContext, IMasterProfileRepository masterProfileRepository, IServicesRepository servicesRepository, IMapper mapper)
        {
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
            _servicesRepository = servicesRepository;
            _mapper = mapper;
        }
        public  async Task<Result<List<DtoServicesInfo>>> Handle(GetServicesSalonForMasterQuery query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var master = await _masterProfileRepository.GetMasterProfileByUserId(userId);
            if(master == null)
                return Result.Failure<List<DtoServicesInfo>>("Профиль мастера не найден");
            var services = await _servicesRepository.GetServicesBySalon(master.SalonId);
            var result = _mapper.Map<List<DtoServicesInfo>>(services);
            return Result.Success(result);
        }
    }
}