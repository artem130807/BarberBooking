using AutoMapper;
using IdentityService.Application.Dto;
using IdentityService.Application.Dto.Users;
using IdentityService.Domain.Models;
using IdentityService.Domain.ValueObjects;

namespace IdentityService.Application.MapperProfiles;

public class UserMappingProfile : Profile
{
    public UserMappingProfile()
    {
        CreateMap<Users, UserInfoDto>();
        CreateMap<Users, DtoUserProfile>()
            .ForMember(dest => dest.Phone, opt => opt.MapFrom(src => src.Phone));

        CreateMap<PhoneNumber, DtoPhone>()
            .ForMember(dest => dest.Number, opt => opt.MapFrom(src => src.Number));
    }
}
