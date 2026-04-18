using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoSalonPhotos;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.SalonPhotos.Queries
{
    public record GetSalonPhotosQuery(Guid salonId, PageParams pageParams):IRequest<Result<PagedResult<DtoSalonPhoto>>>;
}