using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Dto;
using BarberBooking.API.Dto.DtoServices;
using BarberBooking.API.Models;

namespace BarberBooking.API.Service.UpdateService
{
    public class UpdateServicesService : IUpdateServicesService
    {
        public async Task UpdateAsync(Services services, DtoUpdateServices? dto)
        {
            var name = !string.IsNullOrWhiteSpace(dto.Name) ? dto.Name : services.Name;
            services.UpdateName(name);
            var description = !string.IsNullOrWhiteSpace(dto.Description) ? dto.Description : services.Description;
            services.UpdateDescription(description);
            var durationMinutes = dto.DurationMinutes.HasValue ? dto.DurationMinutes : services.DurationMinutes;
            services.UpdateDurationMinutes(durationMinutes.Value);
            var photo = !string.IsNullOrWhiteSpace(dto.Photo) ? dto.Photo : services.PhotoUrl;
            services.UpdatePhoto(photo);
            var isActive = dto.IsActive.HasValue ? dto.IsActive : services.IsActive;
            services.UpdateIsActive(isActive.Value);
            await UpdatePrice(services, dto.Price);
        }
        private async Task UpdatePrice(Services services, DtoUpdatePrice? dto)
        {
            if(dto == null) return;
            var price = dto.Value.HasValue ? dto.Value.Value : services.Price.Value;
            var valueObject = Price.Create(price);
            services.UpdatePrice(valueObject.Value);
        }
    }
}