using System;
using AutoMapper;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Enums;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;

namespace BarberBooking.API.MapperProfiles
{
    public class AppointmentMappingProfile : Profile
    {
        public AppointmentMappingProfile()
        {
            CreateMap<Appointments, DtoAppointmentAwaitingReview>()
                .ForMember(dest => dest.dtoMasterProfileNavigation, opt => opt.MapFrom(src => src.Master))
                .ForMember(dest => dest.dtoServicesNavigation, opt => opt.MapFrom(src => src.Service))
                .ForMember(dest => dest.dtoSalonNavigation, opt => opt.MapFrom(src => src.Salon));

            CreateMap<PagedResult<Appointments>, PagedResult<DtoAppointmentAwaitingReview>>()
                .ForMember(dest => dest.Data, opt => opt.MapFrom(src => src.Data))
                .ForMember(dest => dest.Count, opt => opt.MapFrom(src => src.Count));

            CreateMap<Appointments, DtoCreateAppointmentInfo>();
            CreateMap<Appointments, DtoClientAppointmentInfo>()
                .ForMember(dest => dest.dtoMasterProfileNavigation, opt => opt.MapFrom(src => src.Master))
                .ForMember(dest => dest.dtoServicesNavigation, opt => opt.MapFrom(src => src.Service))
                .ForMember(dest => dest.SalonName, opt => opt.MapFrom(src => src.Salon.Name));

            CreateMap<Appointments, DtoClientAppointmentShortInfo>()
                .ForMember(dest => dest.MasterProfileNavigation, opt => opt.MapFrom(src => src.Master))
                .ForMember(dest => dest.SalonNavigation, opt => opt.MapFrom(src => src.Salon))
                .ForMember(dest => dest.ServiceName, opt => opt.MapFrom(src => src.Service.Name))
                .ForMember(dest => dest.Price, opt => opt.MapFrom(src => src.Service.Price));

            CreateMap<DtoCreateAppointment, Appointments>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.Status, opt => opt.MapFrom(src => AppointmentStatusEnum.Confirmed))
                .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
                .ForMember(dest => dest.UpdatedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
                .ForMember(dest => dest.EndTime, opt => opt.MapFrom(src => src.StartTime));

            CreateMap<DtoCreateAppointmentInfo, Appointments>()
                .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
                .ForMember(dest => dest.UpdatedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
                .ForMember(dest => dest.EndTime, opt => opt.MapFrom(src => src.StartTime));

            CreateMap<Appointments, DtoMasterAppointmentInfo>()
                .ForMember(dest => dest.dtoUsersNavigation, opt => opt.MapFrom(src => src.Client))
                .ForMember(dest => dest.dtoServicesNavigation, opt => opt.MapFrom(src => src.Service))
                .ForMember(dest => dest.SalonName, opt => opt.MapFrom(src => src.Salon.Name));

            CreateMap<Appointments, DtoMasterAppointmentShortInfo>()
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.Client.Name))
                .ForMember(dest => dest.ServiceName, opt => opt.MapFrom(src => src.Service.Name))
                .ForMember(dest => dest.Price, opt => opt.MapFrom(src => src.Service.Price));

            CreateMap<DtoUpdateAppointment, Appointments>()
                .ForMember(dest => dest.UpdatedAt, opt => opt.MapFrom(src => DateTime.UtcNow))
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
            CreateMap<Appointments, DtoAppointmentNavigation>()
                .ForMember(dest => dest.ServiceName, opt => opt.MapFrom(src => src.Service.Name))
                .ForMember(dest => dest.Price, opt => opt.MapFrom(src => src.Service.Price))
                .ForMember(dest => dest.PhotoUrl, opt => opt.MapFrom(src => src.Service.PhotoUrl));

            CreateMap<Appointments, DtoSalonAppointmentAdmin>()
                .ForMember(dest => dest.dtoUsersNavigation, opt => opt.MapFrom(src => src.Client))
                .ForMember(dest => dest.dtoMasterProfileNavigation, opt => opt.MapFrom(src => src.Master))
                .ForMember(dest => dest.dtoServicesNavigation, opt => opt.MapFrom(src => src.Service))
                .ForMember(dest => dest.SalonName, opt => opt.MapFrom(src => src.Salon.Name))
                .ForMember(dest => dest.Status, opt => opt.MapFrom(src => src.Status.ToString()));

            CreateMap<PagedResult<Appointments>, PagedResult<DtoSalonAppointmentAdmin>>()
                .ForMember(dest => dest.Data, opt => opt.MapFrom(src => src.Data))
                .ForMember(dest => dest.Count, opt => opt.MapFrom(src => src.Count));
        }
    }
}
