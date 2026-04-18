using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.SalonsAdminContracts;
using BarberBooking.API.Dto.DtoMasterProfile;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Users.QueriesUser.Handlers
{
    public class GetUserProfileByIdForAdminHandler : IRequestHandler<GetMasterProfileByIdForAdminQuery, Result<DtoMasterProfileInfoForAdmin>>
    {
        private readonly IMasterProfileRepository _masterProfileRepository;
        private readonly IMapper _mapper;
        private readonly AdminSalonAccess _adminSalonAccess;
        public GetUserProfileByIdForAdminHandler(IMasterProfileRepository masterProfileRepository, IMapper mapper, AdminSalonAccess adminSalonAccess)
        {
            _masterProfileRepository = masterProfileRepository;
            _mapper = mapper;
            _adminSalonAccess = adminSalonAccess;
        }
        public async Task<Result<DtoMasterProfileInfoForAdmin>> Handle(GetMasterProfileByIdForAdminQuery query, CancellationToken cancellationToken)
        {
            var masterProfile = await _masterProfileRepository.GetMasterProfileById(query.Id);
            if(masterProfile == null)
                return Result.Failure<DtoMasterProfileInfoForAdmin>("Профиль мастера не найден");
            var access = await _adminSalonAccess.RequireSalonAsync(masterProfile.SalonId, cancellationToken);
            if (access.IsFailure)
                return Result.Failure<DtoMasterProfileInfoForAdmin>(access.Error);
            var dto =  _mapper.Map<DtoMasterProfileInfoForAdmin>(masterProfile);
            return Result.Success(dto);
        }
    }
}