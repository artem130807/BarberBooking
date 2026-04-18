using AutoMapper;
using BarberBooking.API.Dto.DtoRefreshTokens;
using BarberBooking.API.Models;

namespace BarberBooking.API.MapperProfiles
{
    public class RefreshTokenMappingProfile : Profile
    {
        public RefreshTokenMappingProfile()
        {
            CreateMap<RefreshToken, DtoRefreshTokenInfo>();
        }
    }
}
