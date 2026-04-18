using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoRefreshTokens;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.RefreshTokens.Queries.Handlers
{
    public class GetRefreshTokensByUserHandlers : IRequestHandler<GetRefreshTokensByUserQueries, Result<List<DtoRefreshTokenInfo>>>
    {
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        private readonly IMapper _mapper;
        private readonly IUserContext _userContext;
        public GetRefreshTokensByUserHandlers(IRefreshTokenRepository refreshTokenRepository, IMapper mapper, IUserContext userContext)
        {
            _refreshTokenRepository = refreshTokenRepository;
            _mapper = mapper;
            _userContext = userContext;
        }
        public async Task<Result<List<DtoRefreshTokenInfo>>> Handle(GetRefreshTokensByUserQueries query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var refreshTokens = await _refreshTokenRepository.GetRefreshTokens(userId);
            var result = _mapper.Map<List<DtoRefreshTokenInfo>>(refreshTokens);
            return Result.Success(result);
        }
    }
}