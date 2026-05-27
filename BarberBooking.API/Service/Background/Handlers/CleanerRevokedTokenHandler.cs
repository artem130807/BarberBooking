using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;

namespace BarberBooking.API.Service.Background.Handlers
{
    public class CleanerRevokedTokenHandler : ICleanerRevokedTokenHandler
    {
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<CleanerRevokedTokenHandler> _logger;
        public CleanerRevokedTokenHandler(IRefreshTokenRepository refreshTokenRepository, IUnitOfWork unitOfWork, ILogger<CleanerRevokedTokenHandler> logger)
        {
            _refreshTokenRepository = refreshTokenRepository;
            _unitOfWork = unitOfWork;
            _logger = logger;
        }
        public async Task Handle(CancellationToken cancellationToken)
        {
            var refreshTokens = await _refreshTokenRepository.GetRevokedTokens();
            if(refreshTokens.Count != 0)
            {
                try
                {
                    _unitOfWork.BeginTransaction();
                    await _refreshTokenRepository.RemoveRange(refreshTokens);
                    _unitOfWork.Commit();
                }catch(Exception ex)
                {
                    _unitOfWork.RollBack();
                    _logger.LogError(ex.Message);
                }
            }
            _logger.LogInformation($"Токенов удалено: {refreshTokens.Count}");
        }
    }
}