using AutoMapper;
using BarberBooking.API.Dto.DtoTemplateDay;
using BarberBooking.API.Models;

namespace BarberBooking.API.MapperProfiles
{
    public class TemplateDayMappingProfile : Profile
    {
        public TemplateDayMappingProfile()
        {
            CreateMap<TemplateDay, DtoTemplateDayInfo>()
                .ForMember(d => d.WeeklyTemplateId, o => o.MapFrom(s => s.TemplateId));
        }
    }
}
