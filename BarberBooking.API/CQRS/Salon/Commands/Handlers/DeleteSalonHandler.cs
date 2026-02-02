using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonsContracts;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Salons.Commands.Handlers
{
    public class DeleteSalonHandler : IRequestHandler<DeleteSalonCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ISalonsRepository _salonsRepository;
        public DeleteSalonHandler( IUnitOfWork unitOfWork, ISalonsRepository salonsRepository)
        {
            _unitOfWork = unitOfWork;
            _salonsRepository = salonsRepository;
        }
        public async Task<Result<string>> Handle(DeleteSalonCommand command, CancellationToken cancellationToken)
        {
            var salon = await _salonsRepository.GetSalonById(command.Id);
            if(salon == null)
                return Result.Failure<string>("Салон не найден");
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.salonsRepository.Delete(command.Id);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<string>(ex.Message);
            }
            return Result.Success("Успешно");
        }
    }
}