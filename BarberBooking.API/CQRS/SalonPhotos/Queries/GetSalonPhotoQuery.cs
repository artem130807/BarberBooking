using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoSalonPhotos;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.SalonPhotos.Queries
{
    public record GetSalonPhotoQuery(Guid Id):IRequest<Result<DtoSalonPhoto>>;
}