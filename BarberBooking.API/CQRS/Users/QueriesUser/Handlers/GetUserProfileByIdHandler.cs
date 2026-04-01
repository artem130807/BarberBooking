using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoUsers;
using CSharpFunctionalExtensions;
using EllipticCurve;
using MediatR;

namespace BarberBooking.API.CQRS.Users.QueriesUser.Handlers
{
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
            if(user == null)
                return Result.Failure<DtoUserProfile>("Профиль пользователя не найден");
            var result = _mapper.Map<DtoUserProfile>(user);
            return Result.Success(result);
        }
    }
}