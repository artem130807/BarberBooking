using AutoMapper;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Models;

namespace BarberBooking.API.MapperProfiles
{
    public class SalonStatisticMappingProfile : Profile
    {
        public SalonStatisticMappingProfile()
        {
            CreateMap<SalonStatistic, Salons>();
            CreateMap<SalonStatistic, SalonStatsDto>();
            CreateMap<SalonStatsDto, SalonStatistic>();
        }
    }
}
