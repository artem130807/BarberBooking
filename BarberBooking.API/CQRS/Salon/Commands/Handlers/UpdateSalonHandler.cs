using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Domain.ValueObjects;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Salons.Commands.Handlers
{
    public class UpdateSalonHandler : IRequestHandler<UpdateSalonCommand, Result<Unit>>
    {
        private readonly IUpdateSalonService _updateSalon;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ISalonsRepository _salonsRepository;
        public UpdateSalonHandler(IUpdateSalonService updateSalon, IUnitOfWork unitOfWork, ISalonsRepository salonsRepository)
        {
            _updateSalon = updateSalon;
            _unitOfWork = unitOfWork;
            _salonsRepository = salonsRepository;
        }
        public async Task<Result<Unit>> Handle(UpdateSalonCommand command, CancellationToken cancellationToken)
        {
            var salon = await _salonsRepository.GetSalonById(command.Id);
            if(salon == null)
                return Result.Failure<Unit>("Салон не найден");
             try
            {
                _unitOfWork.BeginTransaction();
                await _updateSalon.UpdateAsync(salon, command.dtoUpdateSalon);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<Unit>($"Ошибка:{ex.Message}");
            }
            return Result.Success(Unit.Value);
        }
    }
}