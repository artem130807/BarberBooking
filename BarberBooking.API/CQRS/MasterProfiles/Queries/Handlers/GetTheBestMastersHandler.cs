using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Dto.DtoMasterProfile;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterProfiles.Queries.Handlers
{
    public class GetTheBestMastersHandler : IRequestHandler<GetTheBestMastersQuery, Result<List<DtoMasterPhotoAndName>>>
    {
        private readonly IMapper _mapper;
        private readonly IMasterProfileRepository _masterProfileRepository;
        private readonly IUserContext _userContext;
        public GetTheBestMastersHandler(IMapper mapper, IMasterProfileRepository masterProfileRepository, IUserContext userContext)
        {
            _mapper = mapper;
            _masterProfileRepository = masterProfileRepository;
            _userContext = userContext;
        }
        public async Task<Result<List<DtoMasterPhotoAndName>>> Handle(GetTheBestMastersQuery query, CancellationToken cancellationToken)
        {
            var userCity = _userContext.UserCity;
            var masters = await _masterProfileRepository.GetTheBestMasters(userCity, query.take);
            if(masters.Count == 0)
                return Result.Failure<List<DtoMasterPhotoAndName>>("Список мастеров пуст");
            
            var result = _mapper.Map<List<DtoMasterPhotoAndName>>(masters);
            return Result.Success(result);
        }
    }
}