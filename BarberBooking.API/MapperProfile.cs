using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Dto;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Dto.DtoMasterSubscription;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using BarberBooking.API.Dto.DtoReview;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Dto.DtoServices;
using BarberBooking.API.Dto.DtoUsers;
using BarberBooking.API.Dto.DtoVo;
using BarberBooking.API.Enums;
using BarberBooking.API.Filters;
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
            CreateMap<Services, DtoServicesNavigation>()
            .ForMember(dest => dest.Price, opt => opt.MapFrom(src => src.Price));
            CreateMap<Services, DtoServicesSearchResult>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Name))
            .ForMember(dest => dest.DurationMinutes, opt => opt.MapFrom(src => src.DurationMinutes))
            .ForMember(dest => dest.Price, opt => opt.MapFrom(src => src.Price))
            .ForMember(dest => dest.PhotoUrl, opt => opt.MapFrom(src => src.PhotoUrl))
            .ForMember(dest => dest.dtoSalonNavigation, opt => opt.MapFrom(src => src.Salon));

            CreateMap<PagedResult<Services>, PagedResult<DtoServicesSearchResult>>()
            .ForMember(dest => dest.Data, opt => opt.MapFrom(src => src.Data))
            .ForMember(dest => dest.Count, opt => opt.MapFrom(src => src.Count));

            ///Салоны
            CreateMap<DtoCreateSalon, Salons>();
            CreateMap<DtoUpdateSalon, Salons>();
            CreateMap<Salons, DtoSalonInfo>();
            CreateMap<Salons, DtoSalonShortInfo>();
            CreateMap<Salons, DtoSalonUpdateInfo>();
            CreateMap<Salons, DtoSalonCreateInfo>()
            .ForMember(dest => dest.DtoAddress, opt => opt.MapFrom(src => src.Address))
            .ForMember(dest => dest.Phone, opt => opt.MapFrom(src => src.PhoneNumber));
            
            CreateMap<Salons, DtoSalonNavigation>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.SalonName, opt => opt.MapFrom(src => src.Name))
            .ForMember(dest => dest.Address, opt => opt.MapFrom(src => src.Address))
            .ForMember(dest => dest.MainPhotoUrl, opt => opt.MapFrom(src => src.MainPhotoUrl))
            .ForMember(dest => dest.Rating, opt => opt.MapFrom(src => src.Rating))
            .ForMember(dest => dest.RatingCount, opt => opt.MapFrom(src => src.RatingCount));

            CreateMap<PagedResult<Salons>, PagedResult<DtoSalonShortInfo>>()
            .ForMember(dest => dest.Data, opt => opt.MapFrom(src => src.Data))
            .ForMember(dest => dest.Count, opt => opt.MapFrom(src => src.Count));
            
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
            CreateMap<MasterProfile, DtoMasterProfileSubscriptionInfo>()
            .ForMember(dest => dest.MasterName, opt => opt.MapFrom(src => src.User.Name))
            .ForMember(dest => dest.SalonNavigation, opt => opt.MapFrom(src => src.Salon));
           
            CreateMap<MasterProfile, DtoMasterProfileInfo>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.User != null ? src.User.Name : string.Empty))
            .ForMember(dest => dest.SalonNavigation, opt => opt.MapFrom(src => src.Salon)) 
            .ForMember(dest => dest.Bio, opt => opt.MapFrom(src => src.Bio))
            .ForMember(dest => dest.Specialization, opt => opt.MapFrom(src => src.Specialization))
            .ForMember(dest => dest.AvatarUrl, opt => opt.MapFrom(src => src.AvatarUrl))
            .ForMember(dest => dest.Rating, opt => opt.MapFrom(src => src.Rating))
            .ForMember(dest => dest.RatingCount, opt => opt.MapFrom(src => src.RatingCount));
            
            CreateMap<MasterProfile, DtoMasterProfileShortInfo>()
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.User != null ? src.User.Name : string.Empty));
            CreateMap<MasterProfile, DtoMasterPhotoAndName>()
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.User != null ? src.User.Name : string.Empty));
            CreateMap<MasterProfile, DtoMasterProfileNavigation>()
            .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.Id))
            .ForMember(dest => dest.MasterName, opt => opt.MapFrom(src => src.User.Name));

            ///Записи
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
            ///Отзывы
            CreateMap<DtoCreateReview, Review>();
            CreateMap<DtoUpdateReview, Review>();
            CreateMap<Review, DtoReviewInfo>();

            CreateMap<Review, DtoReviewMasterShortInfo>()
            .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.Client.Name));
            CreateMap<Review, DtoReviewSalonShortInfo>()
            .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.Client.Name))
            .ForMember(dest => dest.DtoMasterProfileNavigation, opt => opt.MapFrom(src => src.MasterProfile));

            CreateMap<PagedResult<Review>, PagedResult<DtoReviewSalonShortInfo>>()
            .ForMember(dest => dest.Data, opt => opt.MapFrom(src => src.Data))
            .ForMember(dest => dest.Count, opt => opt.MapFrom(src => src.Count));

            CreateMap<PagedResult<Review>, PagedResult<DtoReviewMasterShortInfo>>()
            .ForMember(dest => dest.Data, opt => opt.MapFrom(src => src.Data))
            .ForMember(dest => dest.Count, opt => opt.MapFrom(src => src.Count));

            CreateMap<Review, DtoReviewClientShortInfo>()
            .ForMember(dest => dest.dtoSalonNavigation, opt => opt.MapFrom(src => src.Salon))
            .ForMember(dest => dest.masterProfileNavigation, opt => opt.MapFrom(src => src.MasterProfile))
            .ForMember(dest => dest.dtoAppointmentNavigation, opt => opt.MapFrom(src => src.Appointment));

            CreateMap<PagedResult<Review>, PagedResult<DtoReviewClientShortInfo>>()
            .ForMember(dest => dest.Data, opt => opt.MapFrom(src => src.Data))
            .ForMember(dest => dest.Count, opt => opt.MapFrom(src => src.Count));

            ///Слоты
            CreateMap<DtoCreateMasterTimeSlot, MasterTimeSlot>();
            CreateMap<DtoUpdateMasterTimeSlot, MasterTimeSlot>();
            CreateMap<MasterTimeSlot, DtoMasterTimeSlotInfo>();
            CreateMap<MasterTimeSlot, DtoCreateTimeSlotInfo>();
            CreateMap<MasterTimeSlot, DtoMasterProfileNavigation>();
            
            ///Избранное
            CreateMap<DtoCreateMasterSubscription, MasterSubscription>();
            CreateMap<MasterSubscription, DtoMasterSubscriptionShortInfo>()
            .ForMember(dest => dest.masterProfileNavigation, opt => opt.MapFrom(src => src.MasterProfile));
            ///Пользователи
            CreateMap<Users, DtoUsersNavigation>();
            CreateMap<Users, UserInfoDto>();
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
            CreateMap<PhoneNumber, DtoPhone>()
            .ForMember(dest => dest.Number, opt => opt.MapFrom(src => src.Number)); 
        }
    }
}