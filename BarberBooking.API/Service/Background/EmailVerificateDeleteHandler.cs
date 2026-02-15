using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.EmailContracts;

namespace BarberBooking.API.Service.Background
{
    public class EmailVerificateDeleteHandler : IEmailVerficationHandler
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IEmailVerificationRepository _emailVerificationRepository;
        private ILogger<EmailVerificateDeleteHandler> _logger;
        public EmailVerificateDeleteHandler(IUnitOfWork unitOfWork, IEmailVerificationRepository emailVerificationRepository, ILogger<EmailVerificateDeleteHandler> logger)
        {
            _unitOfWork = unitOfWork;
            _emailVerificationRepository = emailVerificationRepository;
            _logger = logger;
        }
        public async Task Handle(CancellationToken cancellationToken)
        {
            var emailVerifications = await _emailVerificationRepository.GetVerifications();
            _logger.LogInformation($"Количество данных для удаления {emailVerifications.Count}");
            if(emailVerifications.Count > 0)
            {
                try
                {
                    _unitOfWork.BeginTransaction();
                    await _emailVerificationRepository.RemoveRange(emailVerifications);
                    _unitOfWork.Commit();
                }catch(Exception ex)
                {
                    _unitOfWork.RollBack();
                    _logger.LogError(ex.Message);
                }
                _logger.LogInformation("Конец удаления");
            } 
        }
    }
}