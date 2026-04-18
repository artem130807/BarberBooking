using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonPhotosContracts;
using BarberBooking.API.Contracts.SalonsAdminContracts;
using BarberBooking.API.Contracts.SalonsContracts;
using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.Extensions.Logging;

namespace BarberBooking.API.CQRS.SalonPhotos.Commands.Handlers
{
    public class CreateSalonPhotoHandler : IRequestHandler<CreateSalonPhotoCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<CreateSalonPhotoHandler> _logger;
        private readonly ISalonPhotosRepository _salonPhotosRepository;
        private readonly ISalonsRepository _salonsRepository;
        private readonly AdminSalonAccess _adminSalonAccess;
        public CreateSalonPhotoHandler(IUnitOfWork unitOfWork, ILogger<CreateSalonPhotoHandler> logger, ISalonPhotosRepository salonPhotosRepository, ISalonsRepository salonsRepository, AdminSalonAccess adminSalonAccess)
        {
            _unitOfWork = unitOfWork;
            _logger = logger;
            _salonPhotosRepository = salonPhotosRepository;
            _salonsRepository = salonsRepository;
            _adminSalonAccess = adminSalonAccess;
        }
        public async Task<Result<string>> Handle(CreateSalonPhotoCommand command, CancellationToken cancellationToken)
        {
            var access = await _adminSalonAccess.RequireSalonAsync(command.dtoCreateSalonPhoto.SalonId, cancellationToken);
            if (access.IsFailure)
                return Result.Failure<string>(access.Error);
            var salon = await _salonsRepository.GetSalonById(command.dtoCreateSalonPhoto.SalonId);
            if(salon == null)
                return Result.Failure<string>("Салон не найден");
            var salonPhotos = await _salonPhotosRepository.GetPhotos(command.dtoCreateSalonPhoto.SalonId);
            if(salonPhotos.Count == 5)
                return Result.Failure<string>("Салон может содержать только 5 фотографий");
            var photo = Models.SalonPhotos.Create(command.dtoCreateSalonPhoto.PhotoUrl, command.dtoCreateSalonPhoto.SalonId);
            if (photo.IsFailure)
                return Result.Failure<string>("Ошибка при создании фотографии");
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.salonPhotosRepository.Add(photo.Value);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                _logger.LogError(ex.Message);
                return Result.Failure<string>("Ошибка при сохранении фотографии");
            }
            return Result.Success("Успешно");
        }
    }
}