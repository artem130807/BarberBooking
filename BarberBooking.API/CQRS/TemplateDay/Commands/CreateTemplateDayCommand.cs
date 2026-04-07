using BarberBooking.API.Dto.DtoTemplateDay;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.TemplateDay.Commands
{
    public record CreateTemplateDayCommand(DtoCreateTemplateDay Dto) : IRequest<Result<string>>;
}
