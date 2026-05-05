using AutoMapper;
using CSharpFunctionalExtensions;
using IdentityService.Application.Contracts;
using IdentityService.Application.Dto;
using MediatR;

namespace IdentityService.Application.CQRS.Users.Queries.Handlers;

public class GetUserByTokenIdHandler : IRequestHandler<GetUserByTokenIdQuery, Result<UserInfoDto>>
{
    private readonly IUserContext _userContext;
    private readonly IUserRepository _userRepository;
    private readonly IMapper _mapper;

    public GetUserByTokenIdHandler(IUserContext userContext, IUserRepository userRepository, IMapper mapper)
    {
        _userContext = userContext;
        _userRepository = userRepository;
        _mapper = mapper;
    }

    public async Task<Result<UserInfoDto>> Handle(GetUserByTokenIdQuery query, CancellationToken cancellationToken)
    {
        var userId = _userContext.UserId;
        var userProfile = await _userRepository.GetUserById(userId);
        if (userProfile == null)
            return Result.Failure<UserInfoDto>("РџСЂРѕС„РёР»СЊ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ РЅРµ РЅР°Р№РґРµРЅ");

        return Result.Success(_mapper.Map<UserInfoDto>(userProfile));
    }
}
