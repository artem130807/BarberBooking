using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.CQRS.Salons.Commands;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Dto.DtoSalons;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Salon.Commands.Handlers
{
    public class CreateSalonHandler : IRequestHandler<CreateSalonCommand, Result<DtoSalonCreateInfo>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        public CreateSalonHandler(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }
        public async Task<Result<DtoSalonCreateInfo>> Handle(CreateSalonCommand command, CancellationToken cancellationToken)
        {
            var dtoSalon = _mapper.Map<Models.Salons>(command.dtoCreateSalon);
            var phone = PhoneNumber.Create(command.dtoCreateSalon.Phone.Number);
            if (phone.IsFailure)
                  return Result.Failure<DtoSalonCreateInfo>($"Ошибка:{phone.Error}");
            var address = Address.Create(command.dtoCreateSalon.DtoAddress.City, command.dtoCreateSalon.DtoAddress.Street,command.dtoCreateSalon.DtoAddress.HouseNumber, command.dtoCreateSalon.DtoAddress.Apartment);
            if (address.IsFailure)
                  return Result.Failure<DtoSalonCreateInfo>($"Ошибка:{address.Error}");
            var salon = Models.Salons.Create(dtoSalon.Name, dtoSalon.Description , address.Value, phone.Value, dtoSalon.OpeningTime, dtoSalon.ClosingTime, dtoSalon.MainPhotoUrl);
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.salonsRepository.Add(salon);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<DtoSalonCreateInfo>($"Ошибка:{ex.Message}");
            }
            var result = _mapper.Map<DtoSalonCreateInfo>(salon);
            return Result.Success(result);
        }
    }
}