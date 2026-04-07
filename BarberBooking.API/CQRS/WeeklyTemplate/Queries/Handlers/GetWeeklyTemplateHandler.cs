using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.WeeklyTemplateContracts;
using BarberBooking.API.Dto.DtoWeeklyTemplate;
using CSharpFunctionalExtensions;
using EllipticCurve;
using MediatR;

namespace BarberBooking.API.CQRS.WeeklyTemplate.Queries.Handlers
{
    public class GetWeeklyTemplateHandler : IRequestHandler<GetWeeklyTemplateQuery, Result<DtoWeeklyTemplateInfo>>
    {
        private readonly IWeeklyTemplateRepository _weeklyTemplateRepository;
        public GetWeeklyTemplateHandler(IWeeklyTemplateRepository weeklyTemplateRepository)
        {
            _weeklyTemplateRepository = weeklyTemplateRepository;
        }
        public async Task<Result<DtoWeeklyTemplateInfo>> Handle(GetWeeklyTemplateQuery query, CancellationToken cancellationToken)
        {
            var weeklyTemplate = await _weeklyTemplateRepository.GetWeeklyTemplate(query.Id);
            if(weeklyTemplate == null)
                return Result.Failure<DtoWeeklyTemplateInfo>("Шаблон не найден");
            var result = new DtoWeeklyTemplateInfo
            {
                Id = weeklyTemplate.Id,
                Name = weeklyTemplate.Name,
                IsActive = weeklyTemplate.IsActive,
                TemplateDayCount = weeklyTemplate.TemplateDays.Count()
            };
            return Result.Success(result);
        }
    }
}