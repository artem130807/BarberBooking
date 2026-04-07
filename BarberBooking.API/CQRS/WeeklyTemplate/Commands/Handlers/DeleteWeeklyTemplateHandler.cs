using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.WeeklyTemplateContracts;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.WeeklyTemplate.Commands.Handlers
{
    public class DeleteWeeklyTemplateHandler:IRequestHandler<DeleteWeeklyTemplateCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IWeeklyTemplateRepository _weeklyTemplateRepository;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;

        public DeleteWeeklyTemplateHandler(
            IUnitOfWork unitOfWork,
            IWeeklyTemplateRepository weeklyTemplateRepository,
            IUserContext userContext,
            IMasterProfileRepository masterProfileRepository)
        {
            _unitOfWork = unitOfWork;
            _weeklyTemplateRepository = weeklyTemplateRepository;
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
        }

        public async Task<Result<string>> Handle(DeleteWeeklyTemplateCommand command, CancellationToken cancellationToken)
        {
            var master = await _masterProfileRepository.GetMasterProfileByUserId(_userContext.UserId);
            if (master == null)
                return Result.Failure<string>("Профиль мастера не найден");

            var weeklyTemplate = await _weeklyTemplateRepository.GetWeeklyTemplate(command.Id);
            if(weeklyTemplate == null)
                return Result.Failure<string>("Элемент не найден");
            if (weeklyTemplate.MasterProfileId != master.Id)
                return Result.Failure<string>("Нет доступа");
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.weeklyTemplateRepository.Delete(command.Id);
                _unitOfWork.Commit();
            }   catch(Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<string>($"Ошибка {ex.Message}");
            }    
            return Result.Success("Успешно");       
        }
    }
}