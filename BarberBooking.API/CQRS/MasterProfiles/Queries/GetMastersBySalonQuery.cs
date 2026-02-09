using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterProfile;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterProfile.Queries
{
    public record GetMastersBySalonQuery(Guid salonId):IRequest<Result<List<DtoMasterProfileShortInfo>>>;
}