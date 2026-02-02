using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Dto;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Models;

namespace BarberBooking.API.Service.UpdateService
{
    public class UpdateSalonService : IUpdateSalonService
    {
        public async Task UpdateAsync(Salons salon, DtoUpdateSalon? dto)
        {
            var name = !string.IsNullOrWhiteSpace(dto.Name) ? dto.Name : dto.Name;
            salon.UpdateName(name);
            var description = !string.IsNullOrWhiteSpace(dto.Description) ? dto.Description : salon.Description;
            salon.UpdateDescription(description);
            var openingTime = dto.OpeningTime.HasValue ? dto.OpeningTime : salon.OpeningTime;
            salon.UpdateOpeningTime(openingTime.Value);
            var closingTime = dto.ClosingTime.HasValue ? dto.ClosingTime : salon.ClosingTime;
            salon.UpdateOpeningTime(closingTime.Value);
            var mainPhotoUrl = !string.IsNullOrWhiteSpace(dto.MainPhotoUrl) ? dto.MainPhotoUrl : salon.MainPhotoUrl;
            salon.UpdateMainPhotoUrl(mainPhotoUrl);
            await UpdateAddress(salon, dto.Address);
            await UpdatePhone(salon, dto.PhoneNumber);
        }
        private async Task UpdateAddress(Salons salon, DtoUpdateAddress? dto)
        {
            if(dto == null) return;
            var city = !string.IsNullOrWhiteSpace(dto.City) 
            ? dto.City 
            : salon.Address.City;
            var street = !string.IsNullOrWhiteSpace(dto.Street) 
            ? dto.Street
            : salon.Address.Street;
            var housenumber = !string.IsNullOrWhiteSpace(dto.HouseNumber) 
            ? dto.HouseNumber
            : salon.Address.HouseNumber;
            var address = Address.Create(city, street, housenumber, dto.Apartment ?? string.Empty);   
            if(address.IsFailure)
                throw new InvalidOperationException($"Адрес: {address.Error}");
            salon.UpdateAddress(address.Value);
        }
        private async Task UpdatePhone(Salons salon, DtoUpdatePhone? dtoPhone)
        {
            if(dtoPhone == null) return;
            var phoneNumber = !string.IsNullOrWhiteSpace(dtoPhone.Number) ? dtoPhone.Number : salon.PhoneNumber.Number;
            var phone = PhoneNumber.Create(phoneNumber);
            if(phone.IsFailure)
                throw new InvalidOperationException($"Телефон: {phone.Error}");
            salon.UpdatePhoneNumber(phone.Value);
        }
    }
}