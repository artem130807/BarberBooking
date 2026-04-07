using System;
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
    public class DeleteTemplateDayHandler : IRequestHandler<DeleteTemplateDayCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ITemplateDayRepository _templateDayRepository;
        private readonly IWeeklyTemplateRepository _weeklyTemplateRepository;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;

        public DeleteTemplateDayHandler(
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

        public async Task<Result<string>> Handle(DeleteTemplateDayCommand command, CancellationToken cancellationToken)
        {
            var master = await _masterProfileRepository.GetMasterProfileByUserId(_userContext.UserId);
            if (master == null)
                return Result.Failure<string>("Профиль мастера не найден");

            var templateDay = await _templateDayRepository.GetById(command.Id);
            if (templateDay == null)
                return Result.Failure<string>("День шаблона не найден");

            var weekly = await _weeklyTemplateRepository.GetWeeklyTemplate(templateDay.TemplateId);
            if (weekly == null || weekly.MasterProfileId != master.Id)
                return Result.Failure<string>("Нет доступа");

            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.templateDayRepository.Delete(command.Id);
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
