using BarberBooking.API.Dto.DtoMedia;
using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.AspNetCore.Http;

namespace BarberBooking.API.CQRS.Media.Commands;

public record UploadAdminImageCommand(IFormFile? File, string PublicBaseUrl)
    : IRequest<Result<DtoUploadAdminImageResult>>;
