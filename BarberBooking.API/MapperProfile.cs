using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Dto;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Dto.DtoServices;
using BarberBooking.API.Dto.DtoVo;
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
            ///Салоны
            CreateMap<DtoCreateSalon, Salons>();
            CreateMap<DtoUpdateSalon, Salons>();
            CreateMap<Salons, DtoSalonInfo>();
            CreateMap<Salons, DtoSalonShortInfo>();
            CreateMap<Salons, DtoSalonUpdateInfo>();
            CreateMap<Salons, DtoSalonCreateInfo>();
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