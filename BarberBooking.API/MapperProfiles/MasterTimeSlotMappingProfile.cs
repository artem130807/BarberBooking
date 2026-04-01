using AutoMapper;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using BarberBooking.API.Models;

namespace BarberBooking.API.MapperProfiles
{
    public class MasterTimeSlotMappingProfile : Profile
    {
        public MasterTimeSlotMappingProfile()
        {
            CreateMap<DtoCreateMasterTimeSlot, MasterTimeSlot>();
            CreateMap<DtoUpdateMasterTimeSlot, MasterTimeSlot>();
            CreateMap<MasterTimeSlot, DtoMasterTimeSlotInfo>();
            CreateMap<MasterTimeSlot, DtoCreateTimeSlotInfo>();
            CreateMap<MasterTimeSlot, DtoMasterProfileNavigation>();
        }
    }
}
