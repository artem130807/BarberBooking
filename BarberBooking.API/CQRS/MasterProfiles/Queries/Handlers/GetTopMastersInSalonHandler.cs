using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.SalonsAdminContracts;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterProfile.Queries
{
    public class GetTopMastersInSalonHandler : IRequestHandler<GetTopMastersInSalonQuery, Result<PagedResult<DtoMasterProfileInfo>>>
    {
        private readonly IMasterProfileRepository _masterProfileRepository;
        private readonly IMapper _mapper;
        private readonly AdminSalonAccess _adminSalonAccess;

        public GetTopMastersInSalonHandler(IMasterProfileRepository masterProfileRepository, IMapper mapper, AdminSalonAccess adminSalonAccess)
        {
            _masterProfileRepository = masterProfileRepository;
            _mapper = mapper;
            _adminSalonAccess = adminSalonAccess;
        }

        public async Task<Result<PagedResult<DtoMasterProfileInfo>>> Handle(GetTopMastersInSalonQuery query, CancellationToken cancellationToken)
        {
            var access = await _adminSalonAccess.RequireSalonAsync(query.salonId, cancellationToken);
            if (access.IsFailure)
                return Result.Failure<PagedResult<DtoMasterProfileInfo>>(access.Error);
            var masters = await _masterProfileRepository.GetTopMastersInSalon(query.salonId, query.pageParams);
            var result = _mapper.Map<PagedResult<DtoMasterProfileInfo>>(masters);
            return Result.Success(result);
        }
    }
}
