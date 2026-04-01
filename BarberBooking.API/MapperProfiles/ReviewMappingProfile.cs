using AutoMapper;
using BarberBooking.API.Dto.DtoReview;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;

namespace BarberBooking.API.MapperProfiles
{
    public class ReviewMappingProfile : Profile
    {
        public ReviewMappingProfile()
        {
            CreateMap<DtoCreateReview, Review>();
            CreateMap<DtoUpdateReview, Review>();
            CreateMap<Review, DtoReviewInfo>();

            CreateMap<Review, DtoReviewMasterShortInfo>()
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.Client.Name));
            CreateMap<Review, DtoReviewSalonShortInfo>()
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.Client.Name))
                .ForMember(dest => dest.DtoMasterProfileNavigation, opt => opt.MapFrom(src => src.MasterProfile));

            CreateMap<PagedResult<Review>, PagedResult<DtoReviewSalonShortInfo>>()
                .ForMember(dest => dest.Data, opt => opt.MapFrom(src => src.Data))
                .ForMember(dest => dest.Count, opt => opt.MapFrom(src => src.Count));

            CreateMap<PagedResult<Review>, PagedResult<DtoReviewMasterShortInfo>>()
                .ForMember(dest => dest.Data, opt => opt.MapFrom(src => src.Data))
                .ForMember(dest => dest.Count, opt => opt.MapFrom(src => src.Count));

            CreateMap<Review, DtoReviewClientShortInfo>()
                .ForMember(dest => dest.dtoSalonNavigation, opt => opt.MapFrom(src => src.Salon))
                .ForMember(dest => dest.masterProfileNavigation, opt => opt.MapFrom(src => src.MasterProfile))
                .ForMember(dest => dest.dtoAppointmentNavigation, opt => opt.MapFrom(src => src.Appointment));

            CreateMap<PagedResult<Review>, PagedResult<DtoReviewClientShortInfo>>()
                .ForMember(dest => dest.Data, opt => opt.MapFrom(src => src.Data))
                .ForMember(dest => dest.Count, opt => opt.MapFrom(src => src.Count));

            CreateMap<Review, DtoReviewAdminListItem>()
                .ForMember(dest => dest.ClientName, opt => opt.MapFrom(src => src.Client != null ? src.Client.Name : string.Empty))
                .ForMember(dest => dest.dtoSalonNavigation, opt => opt.MapFrom(src => src.Salon))
                .ForMember(dest => dest.masterProfileNavigation, opt => opt.MapFrom(src => src.MasterProfile))
                .ForMember(dest => dest.dtoAppointmentNavigation, opt => opt.MapFrom(src => src.Appointment));

            CreateMap<PagedResult<Review>, PagedResult<DtoReviewAdminListItem>>()
                .ForMember(dest => dest.Data, opt => opt.MapFrom(src => src.Data))
                .ForMember(dest => dest.Count, opt => opt.MapFrom(src => src.Count));
        }
    }
}
