using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoServices;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Services.ServicesQueries
{
    public class GetServicesSalonForMasterQuery():IRequest<Result<List<DtoServicesInfo>>>;
}