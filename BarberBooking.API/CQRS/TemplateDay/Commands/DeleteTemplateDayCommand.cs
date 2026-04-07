using System;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.TemplateDay.Commands
{
    public record DeleteTemplateDayCommand(Guid Id) : IRequest<Result<string>>;
}
