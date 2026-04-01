using AutoMapper;
using BarberBooking.API.Dto.DtoMasterSubscription;
using BarberBooking.API.Models;

namespace BarberBooking.API.MapperProfiles
{
    public class MasterSubscriptionMappingProfile : Profile
    {
        public MasterSubscriptionMappingProfile()
        {
            CreateMap<DtoCreateMasterSubscription, MasterSubscription>();
            CreateMap<MasterSubscription, DtoMasterSubscriptionShortInfo>()
                .ForMember(dest => dest.masterProfileNavigation, opt => opt.MapFrom(src => src.MasterProfile));
        }
    }
}
