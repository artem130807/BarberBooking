using System;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.WeeklyTemplateContracts;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.WeeklyTemplate.Commands.Handlers
{
    public class CreateWeeklyTemplateHandler : IRequestHandler<CreateWeeklyTemplateCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IWeeklyTemplateRepository _weeklyTemplateRepository;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;
        public CreateWeeklyTemplateHandler(IUnitOfWork unitOfWork, IWeeklyTemplateRepository weeklyTemplateRepository, IUserContext userContext, IMasterProfileRepository masterProfileRepository)
        {
            _unitOfWork = unitOfWork;
            _weeklyTemplateRepository = weeklyTemplateRepository;
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
        }
        public async Task<Result<string>> Handle(CreateWeeklyTemplateCommand command, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var master = await _masterProfileRepository.GetMasterProfileByUserId(userId);
            if(master == null)
                return Result.Failure<string>("Профиль мастера не найден"); 
            var weeklyTemplate = Models.WeeklyTemplate.Create(master.Id, command.dto.Name, command.dto.IsActive);
            try
            {
             _unitOfWork.BeginTransaction();
                await _unitOfWork.weeklyTemplateRepository.Add(weeklyTemplate);
             _unitOfWork.Commit();   
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<string>($"Ошибка {ex.Message}");
            }
            return Result.Success(weeklyTemplate.Id.ToString());
        }
    }
}