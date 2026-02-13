using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Dto;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Dto.DtoServices;
using BarberBooking.API.Dto.DtoUsers;
using BarberBooking.API.Dto.DtoVo;
using BarberBooking.API.Enums;
using BarberBooking.API.Models;

namespace BarberBooking.API
{
    public class MapperProfile:Profile
    {
        public MapperProfile()
        {
            ///Услуги
            CreateMap<DtoCreateServices, Services>();
            CreateMap<DtoUpdateServices, Services>();
            CreateMap<Services, DtoServicesShortInfo>();
            CreateMap<Services, DtoServicesInfo>();
            CreateMap<Services, DtoServicesNavigation>();
            ///Салоны
            CreateMap<DtoCreateSalon, Salons>();
            CreateMap<DtoUpdateSalon, Salons>();
            CreateMap<Salons, DtoSalonInfo>();
            CreateMap<Salons, DtoSalonShortInfo>();
            CreateMap<Salons, DtoSalonUpdateInfo>();
            CreateMap<Salons, DtoSalonCreateInfo>();
            CreateMap<Salons, DtoSalonNavigation>();
            ///МастерПрофиль
            CreateMap<DtoCreateMasterProfile, MasterProfile>()
            .ForMember(dest => dest.Id, opt => opt.Ignore())
            .ForMember(dest => dest.Rating, opt => opt.MapFrom(src => 0m))
            .ForMember(dest => dest.RatingCount, opt => opt.MapFrom(src => 0))
            .ForMember(dest => dest.CreatedAt, opt => opt.MapFrom(src => DateTime.UtcNow));
        
            CreateMap<DtoUpdateMasterProfile, MasterProfile>()
            .ForMember(dest => dest.Id, opt => opt.Ignore())
            .ForMember(dest => dest.UserId, opt => opt.Ignore())
            .ForMember(dest => dest.SalonId, opt => opt.Ignore())
            .ForMember(dest => dest.Rating, opt => opt.Ignore())
            .ForMember(dest => dest.RatingCount, opt => opt.Ignore())
            .ForMember(dest => dest.CreatedAt, opt => opt.Ignore());

            CreateMap<MasterProfile, DtoCreateProfileInfo>();
            
            CreateMap<MasterProfile, DtoMasterProfileInfo>()
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.User != null ? src.User.Name : string.Empty));
            
            CreateMap<MasterProfile, DtoMasterProfileShortInfo>()
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.User != null ? src.User.Name : string.Empty));
            CreateMap<MasterProfile, DtoMasterProfileNavigation>();
            ///Записи
            CreateMap<Appointments, DtoClientAppointmentInfo>()
            .ForMember(dest => dest.dtoMasterProfileNavigation, opt => opt.MapFrom(src => src.Master))
            .ForMember(dest => dest.dtoServicesNavigation, opt => opt.MapFrom(src => src.Service))
            .ForMember(dest => dest.SalonName, opt => opt.MapFrom(src => src.Salon.Name));

            CreateMap<Appointments, DtoClientAppointmentShortInfo>()
            .ForMember(dest => dest.MasterName, opt => opt.MapFrom(src => src.Master.User.Name))
            .ForMember(dest => dest.ServiceName, opt => opt.MapFrom(src => src.Service.Name))
            .ForMember(dest => dest.Price, opt => opt.MapFrom(src => src.Service.Price));

            CreateMap<DtoCreateAppointment, Appointments>()
            .ForMember(dest => dest.Id, opt => opt.Ignore())
            .ForMember(dest => dest.Status, opt => opt.MapFrom(src => AppointmentStatusEnum.Pending))
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
            CreateMap<Appointments, DtoAppointmentNavigation>();

            ///Тайм слоты
            CreateMap<DtoCreateMasterTimeSlot, MasterTimeSlot>();
            CreateMap<DtoUpdateMasterTimeSlot, MasterTimeSlot>();
            CreateMap<MasterTimeSlot, DtoMasterTimeSlotInfo>();
            CreateMap<MasterTimeSlot, DtoCreateTimeSlotInfo>();
            CreateMap<MasterTimeSlot, DtoMasterProfileNavigation>();
            ///Пользователи
            CreateMap<Users, DtoUsersNavigation>();
            ///ValueObject
            CreateMap<DtoUpdatePrice, Price>();
            CreateMap<Price, DtoPrice>();
            CreateMap<DtoPrice, Price>();
            CreateMap<DtoUpdateAddress, Address>();
            CreateMap<DtoAddress, Address>();
            CreateMap<Address, DtoAddress>();
            CreateMap<Address, DtoAddressShort>();
            CreateMap<Address, DtoUpdateAddress>();
            CreateMap<PhoneNumber, DtoUpdatePhone>();
           
        }
    }
}