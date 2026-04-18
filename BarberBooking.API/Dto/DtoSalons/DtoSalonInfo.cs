using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoVo;

namespace BarberBooking.API.Dto.DtoSalons
{
    public class DtoSalonInfo
    {
        public Guid Id {get; private set;}
        public string Name {get; private set;}
        public string? Description { get; private set; }
        public DtoAddress Address{get; private set;}
        public DtoPhone? Phone {get; private set;}
        public TimeOnly? OpeningTime { get; private set; }
        public TimeOnly? ClosingTime { get; private set; }
        public bool IsActive {get; private set;} 
        public decimal Rating {get; private set;}
        public int RatingCount {get; private set;}
    }
}