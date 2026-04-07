using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.TemplateDayContracts;
using BarberBooking.API.Contracts.WeeklyTemplateContracts;
using BarberBooking.API.CQRS.TemplateDay.Commands;
using MTemplateDay = BarberBooking.API.Models.TemplateDay;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.TemplateDay.Commands.Handlers
{
    public class CreateTemplateDayHandler : IRequestHandler<CreateTemplateDayCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ITemplateDayRepository _templateDayRepository;
        private readonly IWeeklyTemplateRepository _weeklyTemplateRepository;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;

        public CreateTemplateDayHandler(
            IUnitOfWork unitOfWork,
            ITemplateDayRepository templateDayRepository,
            IWeeklyTemplateRepository weeklyTemplateRepository,
            IUserContext userContext,
            IMasterProfileRepository masterProfileRepository)
        {
            _unitOfWork = unitOfWork;
            _templateDayRepository = templateDayRepository;
            _weeklyTemplateRepository = weeklyTemplateRepository;
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
        }

        public async Task<Result<string>> Handle(CreateTemplateDayCommand command, CancellationToken cancellationToken)
        {
            var dto = command.Dto;
            if (dto.WorkStartTime >= dto.WorkEndTime)
                return Result.Failure<string>("Время начала должно быть раньше времени окончания");

            var master = await _masterProfileRepository.GetMasterProfileByUserId(_userContext.UserId);
            if (master == null)
                return Result.Failure<string>("Профиль мастера не найден");

            var weekly = await _weeklyTemplateRepository.GetWeeklyTemplate(dto.WeeklyTemplateId);
            if (weekly == null)
                return Result.Failure<string>("Шаблон недели не найден");
            if (weekly.MasterProfileId != master.Id)
                return Result.Failure<string>("Нет доступа к шаблону");

            var existing = await _templateDayRepository.GetByWeeklyTemplateId(dto.WeeklyTemplateId);
            if (existing.Any(x => x.DayOfWeek == dto.DayOfWeek))
                return Result.Failure<string>("Этот день недели уже задан в шаблоне");

            var templateDay = MTemplateDay.Create(
                dto.WeeklyTemplateId,
                dto.DayOfWeek,
                dto.WorkStartTime,
                dto.WorkEndTime);

            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.templateDayRepository.Add(templateDay);
                _unitOfWork.Commit();
            }
            catch (Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<string>($"Ошибка: {ex.Message}");
            }

            return Result.Success(templateDay.Id.ToString());
        }
    }
}
