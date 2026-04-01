using System;
using AutoMapper;
using BarberBooking.API.Dto.DtoMasterStatistic;
using BarberBooking.API.Models;

namespace BarberBooking.API.MapperProfiles
{
    public class MasterStatisticMappingProfile : Profile
    {
        public MasterStatisticMappingProfile()
        {
            CreateMap<MasterStatsDto, MasterStatistic>()
                .ForMember(d => d.Id, o => o.MapFrom(_ => Guid.NewGuid()))
                .ForMember(d => d.MasterProfile, o => o.Ignore());
        }
    }
}
