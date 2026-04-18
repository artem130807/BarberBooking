using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Dto.DtoSalonPhotos;
using BarberBooking.API.Models;

namespace BarberBooking.API.MapperProfiles
{
    public class SalonPhotoMappingProfile:Profile
    {
        public SalonPhotoMappingProfile()
        {
            CreateMap<DtoCreateSalonPhoto, SalonPhotos>();
            CreateMap<SalonPhotos, DtoSalonPhoto>();
        }
    }
}