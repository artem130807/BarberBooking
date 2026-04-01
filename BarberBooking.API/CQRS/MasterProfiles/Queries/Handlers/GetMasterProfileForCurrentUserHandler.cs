using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.CQRS.MasterProfile.Queries;
using BarberBooking.API.Dto.DtoMasterProfile;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterProfiles.Queries.Handlers;

public class GetMasterProfileForCurrentUserHandler
    : IRequestHandler<GetMasterProfileForCurrentUserQuery, Result<DtoMasterProfileInfo>>
{
    private readonly IMasterProfileRepository _masterProfileRepository;
    private readonly IMapper _mapper;
    private readonly IUserContext _userContext;

    public GetMasterProfileForCurrentUserHandler(
        IMasterProfileRepository masterProfileRepository,
        IMapper mapper,
        IUserContext userContext)
    {
        _masterProfileRepository = masterProfileRepository;
        _mapper = mapper;
        _userContext = userContext;
    }

    public async Task<Result<DtoMasterProfileInfo>> Handle(
        GetMasterProfileForCurrentUserQuery query,
        CancellationToken cancellationToken)
    {
        var userId = _userContext.UserId;
        var masterProfile = await _masterProfileRepository.GetMasterProfileByUserId(userId);
        if (masterProfile == null)
            return Result.Failure<DtoMasterProfileInfo>("Профиль мастера не найден");

        var isSubscripe =
            await _masterProfileRepository.UserIsSubscripeMaster(userId, masterProfile.Id);
        var dto = _mapper.Map<DtoMasterProfileInfo>(masterProfile);
        dto.IsSubscripe = isSubscripe;
        return Result.Success(dto);
    }
}
