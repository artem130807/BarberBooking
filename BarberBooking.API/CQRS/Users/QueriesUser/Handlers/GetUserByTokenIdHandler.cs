using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Users.QueriesUser.Handlers
{
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
            if(userProfile == null)
                return Result.Failure<UserInfoDto>("Профиль пользователя не найден");
            var result = _mapper.Map<UserInfoDto>(userProfile);
            return Result.Success(result);
        }
    }
}