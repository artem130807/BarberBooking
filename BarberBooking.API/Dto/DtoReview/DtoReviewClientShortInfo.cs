using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.CQRS.Reviews.Queries;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Models;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.Dto.DtoReview
{
    public class DtoReviewClientShortInfo
    {
        public Guid Id {get; private set;}
        public int SalonRating {get; private set;}
        public int? MasterRating {get; private set;}
        public DtoSalonNavigation dtoSalonNavigation {get; private set;}
        public DtoMasterProfileNavigation masterProfileNavigation {get; private set;}
        public DtoAppointmentNavigation dtoAppointmentNavigation {get; private set;}
        public string? Comment {get; private set;}
        public DateTime? CreatedAt {get; private set;}
    }
}