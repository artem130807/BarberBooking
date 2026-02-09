using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Dto.DtoMasterProfile;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterProfile.Queries
{
    public class GetMasterProfileByIdHandler : IRequestHandler<GetMasterProfileByIdQuery, Result<DtoMasterProfileInfo>>
    {
        private readonly IMasterProfileRepository _masterProfileRepository;
        private readonly IMapper _mapper;
        public GetMasterProfileByIdHandler(IMasterProfileRepository masterProfileRepository, IMapper mapper)
        {
            _masterProfileRepository = masterProfileRepository;
            _mapper = mapper;
        }
        public async Task<Result<DtoMasterProfileInfo>> Handle(GetMasterProfileByIdQuery query, CancellationToken cancellationToken)
        {
            var masterProfile = await _masterProfileRepository.GetMasterProfileById(query.Id);
            if(masterProfile == null)
                return Result.Failure<DtoMasterProfileInfo>("Профиль мастера не найден");
            return _mapper.Map<DtoMasterProfileInfo>(masterProfile);
        }
    }
}