using AutoMapper;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Dto;
using BarberBooking.API.Dto.DtoServices;
using BarberBooking.API.Dto.DtoVo;

namespace BarberBooking.API.MapperProfiles
{
    public class ValueObjectMappingProfile : Profile
    {
        public ValueObjectMappingProfile()
        {
            CreateMap<DtoUpdatePrice, Price>();
            CreateMap<Price, DtoPrice>();
            CreateMap<DtoPrice, Price>();
            CreateMap<DtoUpdateAddress, Address>();
            CreateMap<DtoAddress, Address>();
            CreateMap<Address, DtoAddress>();
            CreateMap<Address, DtoAddressShort>();
            CreateMap<Address, DtoUpdateAddress>();
            CreateMap<PhoneNumber, DtoUpdatePhone>();
            CreateMap<PhoneNumber, DtoPhone>()
                .ForMember(dest => dest.Number, opt => opt.MapFrom(src => src.Number));
        }
    }
}
