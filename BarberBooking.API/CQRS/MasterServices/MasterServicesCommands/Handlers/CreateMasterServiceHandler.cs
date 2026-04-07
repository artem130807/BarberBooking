using System;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.CQRS.MasterServices.MasterServicesCommands;
using BarberBooking.API.Dto.DtoMasterServices;
using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.CQRS.MasterServices.MasterServicesCommands.Handlers
{
    public class CreateMasterServiceHandler : IRequestHandler<CreateMasterServiceCommand, Result<DtoMasterServiceInfo>>
    {
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;

        public CreateMasterServiceHandler(
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

        public async Task<Result<DtoMasterServiceInfo>> Handle(
            CreateMasterServiceCommand command,
            CancellationToken cancellationToken)
        {
            var master = await _masterProfileRepository.GetMasterProfileByUserId(_userContext.UserId);
            if (master == null)
                return Result.Failure<DtoMasterServiceInfo>("Доступно только мастеру");

            var service = await _unitOfWork.servicesRepository.GetByIdAsync(command.Dto.ServiceId);
            if (service == null)
                return Result.Failure<DtoMasterServiceInfo>("Услуга не найдена");
            if (service.SalonId != master.SalonId)
                return Result.Failure<DtoMasterServiceInfo>("Услуга не относится к салону мастера");

            if (await _unitOfWork.masterServicesRepository.ExistsAsync(master.Id, service.Id))
                return Result.Failure<DtoMasterServiceInfo>("Услуга уже добавлена");

            var created = BarberBooking.API.Models.MasterServices.Create(master.Id, service.Id);
            if (created.IsFailure)
                return Result.Failure<DtoMasterServiceInfo>(created.Error);

            var entity = created.Value;
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.masterServicesRepository.AddAsync(entity);
                _unitOfWork.Commit();
            }
            catch (DbUpdateException ex)
            {
                _unitOfWork.RollBack();
                if (IsUniqueConstraintViolation(ex))
                    return Result.Failure<DtoMasterServiceInfo>("Услуга уже добавлена");
                return Result.Failure<DtoMasterServiceInfo>(
                    $"Не удалось сохранить: {FormatDbError(ex)}");
            }
            catch (Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<DtoMasterServiceInfo>(ex.Message);
            }

            var dto = _mapper.Map<DtoMasterServiceInfo>(entity);
            dto.ServiceName = service.Name;
            return Result.Success(dto);
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
