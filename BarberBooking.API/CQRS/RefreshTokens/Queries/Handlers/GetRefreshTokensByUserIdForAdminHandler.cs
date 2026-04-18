using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.CQRS.RefreshTokens.Queries;
using BarberBooking.API.Dto.DtoRefreshTokens;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.RefreshTokens.Queries.Handlers
{
    public class GetRefreshTokensByUserIdForAdminHandler
        : IRequestHandler<GetRefreshTokensByUserIdForAdminQuery, Result<List<DtoRefreshTokenInfo>>>
    {
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        private readonly IMapper _mapper;
        private readonly IUserContext _userContext;

        public GetRefreshTokensByUserIdForAdminHandler(
            IRefreshTokenRepository refreshTokenRepository,
            IMapper mapper,
            IUserContext userContext)
        {
            _refreshTokenRepository = refreshTokenRepository;
            _mapper = mapper;
            _userContext = userContext;
        }

        public async Task<Result<List<DtoRefreshTokenInfo>>> Handle(
            GetRefreshTokensByUserIdForAdminQuery query,
            CancellationToken cancellationToken)
        {
            if (!_userContext.IsInRole("Admin"))
                return Result.Failure<List<DtoRefreshTokenInfo>>("Доступ запрещён");
            var refreshTokens = await _refreshTokenRepository.GetRefreshTokens(query.UserId);
            var result = _mapper.Map<List<DtoRefreshTokenInfo>>(refreshTokens);
            return Result.Success(result ?? new List<DtoRefreshTokenInfo>());
        }
    }
}
