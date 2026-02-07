using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;

namespace BarberBooking.API.Dto.DtoSalons
{
    public class DtoUpdateSalon
    {
        public string? Name {get; set;}
        public string? Description { get; set; }
        public DtoUpdateAddress? Address {get; set;}
        public TimeOnly? OpeningTime { get; set; }
        public TimeOnly? ClosingTime { get; set; }
        public string? MainPhotoUrl { get; set; }
        public DtoUpdatePhone? PhoneNumber {get; set;}
    }
}