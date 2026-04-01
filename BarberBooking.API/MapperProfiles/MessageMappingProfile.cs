using AutoMapper;
using BarberBooking.API.Dto.DtoMessages;
using BarberBooking.API.Models;

namespace BarberBooking.API.MapperProfiles
{
    public class MessageMappingProfile : Profile
    {
        public MessageMappingProfile()
        {
            CreateMap<Messages, DtoMessagesShortInfo>();
        }
    }
}
