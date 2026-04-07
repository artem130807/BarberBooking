using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.TemplateDayContracts;
using BarberBooking.API.Contracts.WeeklyTemplateContracts;
using BarberBooking.API.CQRS.TemplateDay.Queries;
using BarberBooking.API.Dto.DtoTemplateDay;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.TemplateDay.Queries.Handlers
{
    public class GetTemplateDaysHandler : IRequestHandler<GetTemplateDaysQuery, Result<List<DtoTemplateDayInfo>>>
    {
        private readonly ITemplateDayRepository _templateDayRepository;
        private readonly IWeeklyTemplateRepository _weeklyTemplateRepository;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;
        private readonly IMapper _mapper;

        public GetTemplateDaysHandler(
            ITemplateDayRepository templateDayRepository,
            IWeeklyTemplateRepository weeklyTemplateRepository,
            IUserContext userContext,
            IMasterProfileRepository masterProfileRepository,
            IMapper mapper)
        {
            _templateDayRepository = templateDayRepository;
            _weeklyTemplateRepository = weeklyTemplateRepository;
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
            _mapper = mapper;
        }

        public async Task<Result<List<DtoTemplateDayInfo>>> Handle(GetTemplateDaysQuery query, CancellationToken cancellationToken)
        {
            var master = await _masterProfileRepository.GetMasterProfileByUserId(_userContext.UserId);
            if (master == null)
                return Result.Failure<List<DtoTemplateDayInfo>>("Профиль мастера не найден");

            var weekly = await _weeklyTemplateRepository.GetWeeklyTemplate(query.WeeklyTemplateId);
            if (weekly == null)
                return Result.Failure<List<DtoTemplateDayInfo>>("Шаблон недели не найден");
            if (weekly.MasterProfileId != master.Id)
                return Result.Failure<List<DtoTemplateDayInfo>>("Нет доступа к шаблону");

            var list = await _templateDayRepository.GetByWeeklyTemplateId(query.WeeklyTemplateId);
            var dto = _mapper.Map<List<DtoTemplateDayInfo>>(list);
            return Result.Success(dto);
        }
    }
}
