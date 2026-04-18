using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Dto.DtoSalonAdmin;
using BarberBooking.API.Models;

namespace BarberBooking.API.MapperProfiles
{
    public class SalonAdminsMappingProfile:Profile
    {
        public SalonAdminsMappingProfile()
        {
            CreateMap<SalonsAdmin, DtoCreateSalonAdmin>();
            CreateMap<DtoCreateSalonAdmin, SalonsAdmin>();
            CreateMap<SalonsAdmin, DtoGetSalonAdmin>()
                .ForMember(dest => dest.dtoSalonNavigation, opt => opt.MapFrom(src => src.Salon));
        }
    }
}