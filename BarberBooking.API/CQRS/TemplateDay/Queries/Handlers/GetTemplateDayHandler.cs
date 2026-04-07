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
    public class GetTemplateDayHandler : IRequestHandler<GetTemplateDayQuery, Result<DtoTemplateDayInfo>>
    {
        private readonly ITemplateDayRepository _templateDayRepository;
        private readonly IWeeklyTemplateRepository _weeklyTemplateRepository;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;
        private readonly IMapper _mapper;

        public GetTemplateDayHandler(
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

        public async Task<Result<DtoTemplateDayInfo>> Handle(GetTemplateDayQuery query, CancellationToken cancellationToken)
        {
            var master = await _masterProfileRepository.GetMasterProfileByUserId(_userContext.UserId);
            if (master == null)
                return Result.Failure<DtoTemplateDayInfo>("Профиль мастера не найден");

            var templateDay = await _templateDayRepository.GetById(query.Id);
            if (templateDay == null)
                return Result.Failure<DtoTemplateDayInfo>("День шаблона не найден");

            var weekly = await _weeklyTemplateRepository.GetWeeklyTemplate(templateDay.TemplateId);
            if (weekly == null || weekly.MasterProfileId != master.Id)
                return Result.Failure<DtoTemplateDayInfo>("Нет доступа");

            var dto = _mapper.Map<DtoTemplateDayInfo>(templateDay);
            return Result.Success(dto);
        }
    }
}
