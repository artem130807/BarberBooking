using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.RefreshTokens.Commands.Handlers
{
    public class RevokedRefreshTokenHandler : IRequestHandler<RevokedRefreshTokenCommand, Result<bool>>
    {
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<RevokedRefreshTokenHandler> _logger;
        private readonly IUserContext _userContext;
        public RevokedRefreshTokenHandler(
            IRefreshTokenRepository refreshTokenRepository,
            IUnitOfWork unitOfWork,
            ILogger<RevokedRefreshTokenHandler> logger,
            IUserContext userContext)
        {
            _refreshTokenRepository = refreshTokenRepository;
            _unitOfWork = unitOfWork;
            _logger = logger;
            _userContext = userContext;
        }
        public async Task<Result<bool>> Handle(RevokedRefreshTokenCommand command, CancellationToken cancellationToken)
        {
            var refreshToken = await _refreshTokenRepository.GetRefreshToken(command.Id);
            if(refreshToken == null)
                return  Result.Failure<bool>("Сессия не найдена");
            if (refreshToken.UserId != _userContext.UserId && !_userContext.IsInRole("Admin"))
                return Result.Failure<bool>("Доступ запрещён");
            try
            {
                _unitOfWork.BeginTransaction();
                refreshToken.RevokedToken();
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                _logger.LogInformation(ex.Message);
                return Result.Failure<bool>("Не удалось завершить сессию");
            }
            return Result.Success(true);
        }
    }
}