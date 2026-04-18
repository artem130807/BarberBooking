using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonsAdminContracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Dto.DtoSalons;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Salons.Commands.Handlers
{
    public class UpdateSalonHandler : IRequestHandler<UpdateSalonCommand, Result<DtoSalonUpdateInfo>>
    {
        private readonly IUpdateSalonService _updateSalon;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ISalonsRepository _salonsRepository;
        private readonly IMapper _mapper;
        private readonly AdminSalonAccess _adminSalonAccess;
        public UpdateSalonHandler(IUpdateSalonService updateSalon, IUnitOfWork unitOfWork, ISalonsRepository salonsRepository, IMapper mapper, AdminSalonAccess adminSalonAccess)
        {
            _updateSalon = updateSalon;
            _unitOfWork = unitOfWork;
            _salonsRepository = salonsRepository;
            _mapper = mapper;
            _adminSalonAccess = adminSalonAccess;
        }
        public async Task<Result<DtoSalonUpdateInfo>> Handle(UpdateSalonCommand command, CancellationToken cancellationToken)
        {
            var access = await _adminSalonAccess.RequireSalonAsync(command.Id, cancellationToken);
            if (access.IsFailure)
                return Result.Failure<DtoSalonUpdateInfo>(access.Error);
            var salon = await _salonsRepository.GetSalonById(command.Id);
            if(salon == null)
                return Result.Failure<DtoSalonUpdateInfo>("Салон не найден");
            try
            {
                _unitOfWork.BeginTransaction();
                await _updateSalon.UpdateAsync(salon, command.dtoUpdateSalon);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<DtoSalonUpdateInfo>($"Ошибка:{ex.Message}");
            }
            var updateSalon = await _salonsRepository.GetSalonById(command.Id);
            var result = _mapper.Map<DtoSalonUpdateInfo>(updateSalon);
            return Result.Success(result);
        }
    }
}