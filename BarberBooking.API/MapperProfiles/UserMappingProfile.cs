using AutoMapper;
using BarberBooking.API.Dto;
using BarberBooking.API.Dto.DtoUsers;
using BarberBooking.API.Models;

namespace BarberBooking.API.MapperProfiles
{
    public class UserMappingProfile : Profile
    {
        public UserMappingProfile()
        {
            CreateMap<Users, DtoUsersNavigation>()
                .ForMember(dest => dest.dtoPhone, opt => opt.MapFrom(src => src.Phone));
            CreateMap<Users, UserInfoDto>();
            CreateMap<Users, DtoUserProfile>()
                .ForMember(dest => dest.Phone, opt => opt.MapFrom(src => src.Phone));
        }
    }
}
