using BarberBooking.API.Dto.DtoMasterProfile;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterProfile.Queries;

public record GetMasterProfileForCurrentUserQuery : IRequest<Result<DtoMasterProfileInfo>>;
