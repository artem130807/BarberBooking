using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.MasterProfileContracts;
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

        public GetTopMastersInSalonHandler(IMasterProfileRepository masterProfileRepository, IMapper mapper)
        {
            _masterProfileRepository = masterProfileRepository;
            _mapper = mapper;
        }

        public async Task<Result<PagedResult<DtoMasterProfileInfo>>> Handle(GetTopMastersInSalonQuery query, CancellationToken cancellationToken)
        {
            var masters = await _masterProfileRepository.GetTopMastersInSalon(query.salonId, query.pageParams);
            var result = _mapper.Map<PagedResult<DtoMasterProfileInfo>>(masters);
            return Result.Success(result);
        }
    }
}
