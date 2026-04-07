using System;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using BarberBooking.API.Models;
using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.CQRS.MasterTimeSlotCommands.Handler
{
    public class MasterTimeSlotCreateAsyncHandler : IRequestHandler<MasterTimeSlotCreateAsyncCommand, Result<DtoMasterTimeSlotInfo>>
    {
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;

        public MasterTimeSlotCreateAsyncHandler(
            IMapper mapper,
            IUnitOfWork unitOfWork,
            IUserContext userContext,
            IMasterProfileRepository masterProfileRepository)
        {
            _mapper = mapper;
            _unitOfWork = unitOfWork;
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
        }

        public async Task<Result<DtoMasterTimeSlotInfo>> Handle(
            MasterTimeSlotCreateAsyncCommand command,
            CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var masterProfile = await _masterProfileRepository.GetMasterProfileByUserId(userId);
            if (masterProfile == null)
                return Result.Failure<DtoMasterTimeSlotInfo>("Профиль мастера не найден.");

            var dto = command.dtoCreateMasterTimeSlot;
            var duplicate = await _unitOfWork.masterTimeSlotRepository.FindSlotAsync(
                masterProfile.Id,
                dto.ScheduleDate,
                dto.StartTime);
            if (duplicate != null)
                return Result.Failure<DtoMasterTimeSlotInfo>(
                    "Слот на эту дату и время уже существует.");

            var timeSlot = Models.MasterTimeSlot.Create(
                masterProfile.Id,
                dto.ScheduleDate,
                dto.StartTime,
                dto.EndTime);
            if (timeSlot.IsFailure)
                return Result.Failure<DtoMasterTimeSlotInfo>("Ошибка при создании слота");

            var entity = timeSlot.Value;
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.masterTimeSlotRepository.CreateAsync(entity);
                _unitOfWork.Commit();
            }
            catch (DbUpdateException ex)
            {
                _unitOfWork.RollBack();
                if (IsUniqueConstraintViolation(ex))
                    return Result.Failure<DtoMasterTimeSlotInfo>(
                        "Слот на эту дату и время уже существует.");
                return Result.Failure<DtoMasterTimeSlotInfo>(
                    $"Не удалось сохранить слот: {FormatDbError(ex)}");
            }
            catch (Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<DtoMasterTimeSlotInfo>(ex.Message);
            }

            var mapped = _mapper.Map<DtoMasterTimeSlotInfo>(entity);
            return Result.Success(mapped);
        }

        private static bool IsUniqueConstraintViolation(DbUpdateException ex)
        {
            if (ex.InnerException is SqlException sql &&
                (sql.Number == 2601 || sql.Number == 2627))
                return true;
            var msg = ex.InnerException?.Message ?? ex.Message;
            return msg.Contains("UNIQUE", StringComparison.OrdinalIgnoreCase)
                   || msg.Contains("duplicate key", StringComparison.OrdinalIgnoreCase);
        }

        private static string FormatDbError(DbUpdateException ex) =>
            ex.InnerException?.Message ?? ex.Message;
    }
}
