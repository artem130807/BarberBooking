using AutoMapper;
using BarberBooking.API.Dto.DtoMasterServices;
using BarberBooking.API.Models;

namespace BarberBooking.API.MapperProfiles
{
    public class MasterServicesMappingProfile : Profile
    {
        public MasterServicesMappingProfile()
        {
            CreateMap<MasterServices, DtoMasterServiceInfo>()
                .ForMember(d => d.ServiceName, o => o.MapFrom(s => s.Service != null ? s.Service.Name : null));
        }
    }
}
