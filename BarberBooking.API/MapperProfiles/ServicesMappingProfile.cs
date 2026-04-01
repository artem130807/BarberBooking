using AutoMapper;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Dto.DtoServices;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;

namespace BarberBooking.API.MapperProfiles
{
    public class ServicesMappingProfile : Profile
    {
        public ServicesMappingProfile()
        {
            CreateMap<DtoCreateServices, Services>();
            CreateMap<DtoUpdateServices, Services>();
            CreateMap<Services, DtoServicesShortInfo>();
            CreateMap<Services, DtoServicesInfo>();
            CreateMap<Services, DtoServicesNavigation>()
                .ForMember(dest => dest.Price, opt => opt.MapFrom(src => src.Price));
            CreateMap<Services, DtoServicesSearchResult>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.Id))
                .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Name))
                .ForMember(dest => dest.DurationMinutes, opt => opt.MapFrom(src => src.DurationMinutes))
                .ForMember(dest => dest.Price, opt => opt.MapFrom(src => src.Price))
                .ForMember(dest => dest.PhotoUrl, opt => opt.MapFrom(src => src.PhotoUrl))
                .ForMember(dest => dest.dtoSalonNavigation, opt => opt.MapFrom(src => src.Salon));

            CreateMap<PagedResult<Services>, PagedResult<DtoServicesSearchResult>>()
                .ForMember(dest => dest.Data, opt => opt.MapFrom(src => src.Data))
                .ForMember(dest => dest.Count, opt => opt.MapFrom(src => src.Count));

            CreateMap<Services, DtoServicesAdminListItem>()
                .ForMember(dest => dest.Price, opt => opt.MapFrom(src => src.Price));

            CreateMap<PagedResult<Services>, PagedResult<DtoServicesAdminListItem>>()
                .ForMember(dest => dest.Data, opt => opt.MapFrom(src => src.Data))
                .ForMember(dest => dest.Count, opt => opt.MapFrom(src => src.Count));
        }
    }
}
