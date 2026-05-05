using AutoMapper;
using CSharpFunctionalExtensions;
using IdentityService.Application.Contracts;
using IdentityService.Application.Dto.Users;
using MediatR;

namespace IdentityService.Application.CQRS.Users.Queries.Handlers;

public class GetUserProfileByIdHandler : IRequestHandler<GetUserProfileByIdQuery, Result<DtoUserProfile>>
{
    private readonly IUserRepository _userRepository;
    private readonly IMapper _mapper;

    public GetUserProfileByIdHandler(IUserRepository userRepository, IMapper mapper)
    {
        _userRepository = userRepository;
        _mapper = mapper;
    }

    public async Task<Result<DtoUserProfile>> Handle(GetUserProfileByIdQuery query, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetUserById(query.Id);
        if (user == null)
            return Result.Failure<DtoUserProfile>("РџСЂРѕС„РёР»СЊ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ РЅРµ РЅР°Р№РґРµРЅ");

        return Result.Success(_mapper.Map<DtoUserProfile>(user));
    }
}
