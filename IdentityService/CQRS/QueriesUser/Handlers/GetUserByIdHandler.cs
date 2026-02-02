using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using IdentityService.Contracts;
using IdentityService.DtoModels;
using MediatR;

namespace IdentityService.CQRS.Queries.Handlers
{
    public class GetUserByIdHandler : IRequestHandler<GetUserByIdQuery, UserInfoDto>
    {
        private readonly IMapper _mapper;
        private readonly IUserRepository _userRepository;
        public GetUserByIdHandler(IMapper mapper, IUserRepository userRepository)
        {
            _mapper = mapper;
            _userRepository = userRepository;
        }
        public async Task<UserInfoDto> Handle(GetUserByIdQuery query, CancellationToken cancellationToken)
        {
            var user = await _userRepository.GetUserById(query.Id);
            return _mapper.Map<UserInfoDto>(user);
        }
    }
}