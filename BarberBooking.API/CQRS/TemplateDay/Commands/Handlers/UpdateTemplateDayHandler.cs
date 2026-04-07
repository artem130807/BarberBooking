using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.TemplateDayContracts;
using BarberBooking.API.Contracts.WeeklyTemplateContracts;
using BarberBooking.API.CQRS.TemplateDay.Commands;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.TemplateDay.Commands.Handlers
{
    public class UpdateTemplateDayHandler : IRequestHandler<UpdateTemplateDayCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ITemplateDayRepository _templateDayRepository;
        private readonly IWeeklyTemplateRepository _weeklyTemplateRepository;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;

        public UpdateTemplateDayHandler(
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

        public async Task<Result<string>> Handle(UpdateTemplateDayCommand command, CancellationToken cancellationToken)
        {
            var dto = command.Dto;
            if (dto.WorkStartTime >= dto.WorkEndTime)
                return Result.Failure<string>("Время начала должно быть раньше времени окончания");

            var master = await _masterProfileRepository.GetMasterProfileByUserId(_userContext.UserId);
            if (master == null)
                return Result.Failure<string>("Профиль мастера не найден");

            var templateDay = await _templateDayRepository.GetById(command.Id);
            if (templateDay == null)
                return Result.Failure<string>("День шаблона не найден");

            var weekly = await _weeklyTemplateRepository.GetWeeklyTemplate(templateDay.TemplateId);
            if (weekly == null || weekly.MasterProfileId != master.Id)
                return Result.Failure<string>("Нет доступа");

            if (dto.DayOfWeek.HasValue && dto.DayOfWeek.Value != templateDay.DayOfWeek)
            {
                var siblings = await _templateDayRepository.GetByWeeklyTemplateId(templateDay.TemplateId);
                if (siblings.Any(x => x.Id != templateDay.Id && x.DayOfWeek == dto.DayOfWeek.Value))
                    return Result.Failure<string>("Этот день недели уже задан в шаблоне");
                templateDay.UpdateDayOfWeek(dto.DayOfWeek.Value);
            }

            templateDay.UpdateWorkStartTime(dto.WorkStartTime);
            templateDay.UpdateWorkEndTime(dto.WorkEndTime);

            try
            {
                _unitOfWork.BeginTransaction();
                _unitOfWork.Commit();
            }
            catch (Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<string>($"Ошибка: {ex.Message}");
            }

            return Result.Success("Успешно");
        }
    }
}
