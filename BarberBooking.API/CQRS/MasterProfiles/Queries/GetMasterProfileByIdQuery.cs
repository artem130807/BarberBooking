using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Dto.DtoMasterSubscription;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterProfile.Queries
{
    public record GetMasterProfileByIdQuery(Guid Id):IRequest<Result<DtoMasterProfileInfo>>;
}