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
    public class CreateSalonHandler : IRequestHandler<CreateSalonCommand, Result<DtoSalonShortInfo>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        public CreateSalonHandler(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }
        public async Task<Result<DtoSalonShortInfo>> Handle(CreateSalonCommand command, CancellationToken cancellationToken)
        {
            var dtoSalon = _mapper.Map<Models.Salons>(command.dtoCreateSalon);
            var phone = PhoneNumber.Create(dtoSalon.PhoneNumber.Number);
            var address = Address.Create(dtoSalon.Address.City, dtoSalon.Address.Street, dtoSalon.Address.HouseNumber, dtoSalon.Address.Apartment);
            var salon = Models.Salons.Create(dtoSalon.Name, dtoSalon.Description , address.Value, phone.Value, dtoSalon.OpeningTime, dtoSalon.ClosingTime, dtoSalon.MainPhotoUrl);
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.salonsRepository.Add(salon);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<DtoSalonShortInfo>($"Ошибка:{ex.Message}");
            }
            var result = _mapper.Map<DtoSalonShortInfo>(salon);
            return Result.Success(result);
        }
    }
}