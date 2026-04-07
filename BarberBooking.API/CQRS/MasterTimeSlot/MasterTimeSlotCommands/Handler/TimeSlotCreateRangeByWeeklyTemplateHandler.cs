using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.TemplateDayContracts;
using BarberBooking.API.Contracts.WeeklyTemplateContracts;
using BarberBooking.API.CQRS.MasterTimeSlot.MasterTimeSlotCommands;
using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.CQRS.MasterTimeSlot.MasterTimeSlotCommands.Handler
{
    public class TimeSlotCreateRangeByWeeklyTemplateHandler: IRequestHandler<TimeSlotCreateRangeByWeeklyTemplateCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ITemplateDayRepository _templateDayRepository;
        private readonly IWeeklyTemplateRepository _weeklyTemplateRepository;
        private readonly ILogger<TimeSlotCreateRangeByWeeklyTemplateHandler> _logger;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;

        public TimeSlotCreateRangeByWeeklyTemplateHandler(
            IUnitOfWork unitOfWork,
            ITemplateDayRepository templateDayRepository,
            IWeeklyTemplateRepository weeklyTemplateRepository,
            ILogger<TimeSlotCreateRangeByWeeklyTemplateHandler> logger,
            IUserContext userContext,
            IMasterProfileRepository masterProfileRepository)
        {
            _unitOfWork = unitOfWork;
            _templateDayRepository = templateDayRepository;
            _weeklyTemplateRepository = weeklyTemplateRepository;
            _logger = logger;
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
        }

        public async Task<Result<string>> Handle(
            TimeSlotCreateRangeByWeeklyTemplateCommand query,
            CancellationToken cancellationToken)
        {
            var master = await _masterProfileRepository.GetMasterProfileByUserId(_userContext.UserId);
            if (master == null)
                return Result.Failure<string>("Профиль мастера не найден");

            var weekly = await _weeklyTemplateRepository.GetWeeklyTemplate(query.weeklyTemplateId);
            if (weekly == null)
                return Result.Failure<string>("Шаблон недели не найден");
            if (weekly.MasterProfileId != master.Id)
                return Result.Failure<string>("Нет доступа к шаблону");

            if (query.dateFrom > query.dateTo)
                return Result.Failure<string>("Дата «с» не может быть позже даты «по»");

            var templateDays = await _templateDayRepository.GetByWeeklyTemplateId(query.weeklyTemplateId);
            if (templateDays.Count == 0)
                return Result.Failure<string>("В шаблоне нет ни одного дня (TemplateDay)");

            var dates = new List<DateOnly>();
            for (var date = query.dateFrom; date <= query.dateTo; date = date.AddDays(1))
                dates.Add(date);

            var timeSlots = new List<Models.MasterTimeSlot>();
            var skippedExisting = 0;

            foreach (var templateDay in templateDays)
            {
                foreach (var date in dates)
                {
                    if (date.DayOfWeek != templateDay.DayOfWeek)
                        continue;

                    var existing = await _unitOfWork.masterTimeSlotRepository.FindSlotAsync(
                        master.Id,
                        date,
                        templateDay.WorkStartTime);
                    if (existing != null)
                    {
                        skippedExisting++;
                        continue;
                    }

                    var timeSlotResult = Models.MasterTimeSlot.Create(
                        master.Id,
                        date,
                        templateDay.WorkStartTime,
                        templateDay.WorkEndTime);

                    if (timeSlotResult.IsFailure)
                    {
                        _logger.LogWarning("Create slot failed: {Error}", timeSlotResult.Error);
                        continue;
                    }

                    timeSlots.Add(timeSlotResult.Value);
                }
            }

            if (timeSlots.Count == 0)
            {
                var hint =
                    skippedExisting > 0
                        ? $" Все {skippedExisting} слотов уже существуют на этот период."
                        : " За выбранные даты нет дней недели из шаблона (или даты не пересекаются с шаблоном).";
                return Result.Failure<string>("Не создано ни одного слота." + hint);
            }

            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.masterTimeSlotRepository.CreateRangeAsync(timeSlots);
                _unitOfWork.Commit();
            }
            catch (DbUpdateException ex)
            {
                _unitOfWork.RollBack();
                _logger.LogError(ex, "Ошибка сохранения слотов по шаблону (unique constraint или БД)");
                return Result.Failure<string>(
                    "Не удалось сохранить слоты. Возможно, часть слотов уже существует: " + ex.InnerException?.Message);
            }
            catch (Exception ex)
            {
                _unitOfWork.RollBack();
                _logger.LogError(ex, "Ошибка сохранения слотов по шаблону");
                return Result.Failure<string>(ex.Message);
            }

            var msg = $"Создано слотов: {timeSlots.Count}.";
            if (skippedExisting > 0)
                msg += $" Пропущено (уже существуют): {skippedExisting}.";
            return Result.Success(msg);
        }
    }
}
