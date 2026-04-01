using System;
using AutoMapper;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;

namespace BarberBooking.API.MapperProfiles
{
    public class MasterEntityMappingProfile : Profile
    {
        public MasterEntityMappingProfile()
        {
            CreateMap<DtoCreateMasterProfile, MasterProfile>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.UserId, opt => opt.Ignore())
                .ForMember(dest => dest.Rating, opt => opt.MapFrom(src => 0m))
                .ForMember(dest => dest.RatingCount, opt => opt.MapFrom(src => 0))
                .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(src => DateTime.UtcNow));

            CreateMap<DtoUpdateMasterProfile, MasterProfile>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.UserId, opt => opt.Ignore())
                .ForMember(dest => dest.SalonId, opt => opt.Ignore())
                .ForMember(dest => dest.Rating, opt => opt.Ignore())
                .ForMember(dest => dest.RatingCount, opt => opt.Ignore())
                .ForMember(dest => dest.CreatedAt, opt => opt.Ignore());

            CreateMap<MasterProfile, DtoCreateProfileInfo>();
            CreateMap<MasterProfile, DtoMasterProfileSubscriptionInfo>()
                .ForMember(dest => dest.MasterName, opt => opt.MapFrom(src => src.User.Name))
                .ForMember(dest => dest.SalonNavigation, opt => opt.MapFrom(src => src.Salon));

            CreateMap<MasterProfile, DtoMasterProfileInfo>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.Id))
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.User != null ? src.User.Name : string.Empty))
                .ForMember(dest => dest.SalonNavigation, opt => opt.MapFrom(src => src.Salon))
                .ForMember(dest => dest.Bio, opt => opt.MapFrom(src => src.Bio))
                .ForMember(dest => dest.Specialization, opt => opt.MapFrom(src => src.Specialization))
                .ForMember(dest => dest.AvatarUrl, opt => opt.MapFrom(src => src.AvatarUrl))
                .ForMember(dest => dest.Rating, opt => opt.MapFrom(src => src.Rating))
                .ForMember(dest => dest.RatingCount, opt => opt.MapFrom(src => src.RatingCount))
                .ForMember(dest => dest.MasterPhone, opt => opt.MapFrom(src => src.User != null ? src.User.Phone.Number : string.Empty));

            CreateMap<MasterProfile, DtoMasterProfileInfoForAdmin>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.Id))
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.User != null ? src.User.Name : string.Empty))
                .ForMember(dest => dest.SalonNavigation, opt => opt.MapFrom(src => src.Salon))
                .ForMember(dest => dest.Bio, opt => opt.MapFrom(src => src.Bio))
                .ForMember(dest => dest.Specialization, opt => opt.MapFrom(src => src.Specialization))
                .ForMember(dest => dest.AvatarUrl, opt => opt.MapFrom(src => src.AvatarUrl))
                .ForMember(dest => dest.Rating, opt => opt.MapFrom(src => src.Rating))
                .ForMember(dest => dest.RatingCount, opt => opt.MapFrom(src => src.RatingCount))
                .ForMember(dest => dest.MasterPhone, opt => opt.MapFrom(src => src.User != null ? src.User.Phone.Number : string.Empty))
                .ForMember(dest => dest.MasterEmail, opt => opt.MapFrom(src => src.User != null ? src.User.Email : string.Empty));

            CreateMap<MasterProfile, DtoMasterProfileShortInfo>()
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.User != null ? src.User.Name : string.Empty));
            CreateMap<MasterProfile, DtoMasterPhotoAndName>()
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.User != null ? src.User.Name : string.Empty));
            CreateMap<MasterProfile, DtoMasterProfileNavigation>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.Id))
                .ForMember(dest => dest.MasterName, opt => opt.MapFrom(src => src.User.Name));

            CreateMap<PagedResult<MasterProfile>, PagedResult<DtoMasterProfileInfo>>()
                .ForMember(dest => dest.Data, opt => opt.MapFrom(src => src.Data))
                .ForMember(dest => dest.Count, opt => opt.MapFrom(src => src.Count));
        }
    }
}
