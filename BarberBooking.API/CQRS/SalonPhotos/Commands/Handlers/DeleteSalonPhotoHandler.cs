using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonPhotosContracts;
using BarberBooking.API.Contracts.SalonsAdminContracts;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.SalonPhotos.Commands.Handlers
{
    public class DeleteSalonPhotoHandler : IRequestHandler<DeleteSalonPhotoCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ISalonPhotosRepository _salonPhotosRepository;
        private readonly ILogger<DeleteSalonPhotoHandler> _logger;
        private readonly AdminSalonAccess _adminSalonAccess;
        public DeleteSalonPhotoHandler(IUnitOfWork unitOfWork, ISalonPhotosRepository salonPhotosRepository, ILogger<DeleteSalonPhotoHandler> logger, AdminSalonAccess adminSalonAccess)
        {
            _unitOfWork = unitOfWork;
            _salonPhotosRepository = salonPhotosRepository;
            _logger = logger;
            _adminSalonAccess = adminSalonAccess;
        }
        public async Task<Result<string>> Handle(DeleteSalonPhotoCommand query, CancellationToken cancellationToken)
        {
            var salonPhoto = await _salonPhotosRepository.GetById(query.Id);
            if(salonPhoto == null)
                return Result.Failure<string>("Фото не найдено");
            var access = await _adminSalonAccess.RequireSalonAsync(salonPhoto.SalonId, cancellationToken);
            if (access.IsFailure)
                return Result.Failure<string>(access.Error);
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.salonPhotosRepository.Delete(query.Id);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                _logger.LogError(ex.Message);
                return Result.Failure<string>("Ошибка при удалении фотографии");
            }
            return Result.Success("Успешное удаление");
        }
    }
}