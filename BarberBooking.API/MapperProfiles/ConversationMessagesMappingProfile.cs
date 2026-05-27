using AutoMapper;
using BarberBooking.API.Dto.DtoConversationMessages;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;

namespace BarberBooking.API.MapperProfiles
{
    public class ConversationMessagesMappingProfile : Profile
    {
        public ConversationMessagesMappingProfile()
        {
            CreateMap<ConversationMessages, DtoConversationMessageInfo>()
                .ForMember(dest => dest.SenderId, opt => opt.MapFrom(src => src.SenderId))
                .ForMember(dest => dest.SenderName, opt => opt.MapFrom(src => src.Sender != null ? src.Sender.Name : string.Empty))
                .ForMember(dest => dest.Content, opt => opt.MapFrom(src => src.Content))
                .ForMember(dest => dest.IsRead, opt => opt.MapFrom(src => src.IsRead))
                .ForMember(dest => dest.SendTime, opt => opt.MapFrom(src => src.CreatedAt));

            CreateMap<ConversationMessages, DtoConversationMessageShortInfo>()
                .ForMember(dest => dest.SenderId, opt => opt.MapFrom(src => src.SenderId))
                .ForMember(dest => dest.SenderName, opt => opt.MapFrom(src => src.Sender != null ? src.Sender.Name : string.Empty))
                .ForMember(dest => dest.Content, opt => opt.MapFrom(src => src.Content))
                .ForMember(dest => dest.IsRead, opt => opt.MapFrom(src => src.IsRead))
                .ForMember(dest => dest.SendTime, opt => opt.MapFrom(src => src.CreatedAt));

            CreateMap<PagedResult<ConversationMessages>, PagedResult<DtoConversationMessageShortInfo>>()
                .ForMember(dest => dest.Data, opt => opt.MapFrom(src => src.Data))
                .ForMember(dest => dest.Count, opt => opt.MapFrom(src => src.Count));
        }
    }
}
