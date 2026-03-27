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

namespace BarberBooking.API.CQRS.MasterProfile.Queries
{
    public class GetMasterProfileByIdHandler : IRequestHandler<GetMasterProfileByIdQuery, Result<DtoMasterProfileInfo>>
    {
        private readonly IMasterProfileRepository _masterProfileRepository;
        private readonly IMapper _mapper;
        private readonly IUserContext _userContext;
        public GetMasterProfileByIdHandler(IMasterProfileRepository masterProfileRepository, IMapper mapper, IUserContext userContext)
        {
            _masterProfileRepository = masterProfileRepository;
            _mapper = mapper;
            _userContext = userContext;
        }
        public async Task<Result<DtoMasterProfileInfo>> Handle(GetMasterProfileByIdQuery query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var masterProfile = await _masterProfileRepository.GetMasterProfileById(query.Id);
            if(masterProfile == null)
                return Result.Failure<DtoMasterProfileInfo>("Профиль мастера не найден");
            bool IsSubcripe = await _masterProfileRepository.UserIsSubscripeMaster(userId, masterProfile.Id);
            var dto =  _mapper.Map<DtoMasterProfileInfo>(masterProfile);
            dto.IsSubscripe = IsSubcripe;
            return Result.Success(dto);
        }
    }
}