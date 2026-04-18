using AutoMapper;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;

namespace BarberBooking.API.MapperProfiles
{
    public class SalonMappingProfile : Profile
    {
        public SalonMappingProfile()
        {
            CreateMap<DtoCreateSalon, Salons>();
            CreateMap<DtoUpdateSalon, Salons>();
            CreateMap<Salons, DtoSalonInfo>()
                .ForMember(dest => dest.Phone, opt => opt.MapFrom(src => src.PhoneNumber));
            CreateMap<Salons, DtoSalonShortInfo>();
            CreateMap<Salons, DtoSalonUpdateInfo>();
            CreateMap<Salons, DtoSalonCreateInfo>()
                .ForMember(dest => dest.DtoAddress, opt => opt.MapFrom(src => src.Address))
                .ForMember(dest => dest.Phone, opt => opt.MapFrom(src => src.PhoneNumber));

            CreateMap<Salons, DtoSalonNavigation>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.Id))
                .ForMember(dest => dest.SalonName, opt => opt.MapFrom(src => src.Name))
                .ForMember(dest => dest.Address, opt => opt.MapFrom(src => src.Address))
                .ForMember(dest => dest.MainPhotoUrl, opt => opt.MapFrom(src => 
                src.SalonPhotos == null ? null : 
                src.SalonPhotos.FirstOrDefault() != null ? src.SalonPhotos.First().PhotoUrl : null))
                .ForMember(dest => dest.Rating, opt => opt.MapFrom(src => src.Rating))
                .ForMember(dest => dest.RatingCount, opt => opt.MapFrom(src => src.RatingCount));

            CreateMap<PagedResult<Salons>, PagedResult<DtoSalonShortInfo>>()
                .ForMember(dest => dest.Data, opt => opt.MapFrom(src => src.Data))
                .ForMember(dest => dest.Count, opt => opt.MapFrom(src => src.Count));

            CreateMap<Salons, DtoSalonAdminStats>()
                .ForMember(dest => dest.Description, opt => opt.MapFrom(src => src.Description))
                .ForMember(dest => dest.Address, opt => opt.MapFrom(src => src.Address))
                .ForMember(dest => dest.Phone, opt => opt.MapFrom(src => src.PhoneNumber))
                .ForMember(dest => dest.MastersCount, opt => opt.MapFrom(src => src.SalonUsers.Count))
                .ForMember(dest => dest.ServicesCount, opt => opt.MapFrom(src => src.Services.Count))
                .ForMember(dest => dest.AppointmentsCount, opt => opt.MapFrom(src => src.Appointments.Count))
                .ForMember(dest => dest.ReviewsCount, opt => opt.MapFrom(src => src.Reviews.Count));
        }
    }
}
