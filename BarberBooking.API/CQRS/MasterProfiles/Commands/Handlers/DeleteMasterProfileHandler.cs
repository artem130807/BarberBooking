using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using CSharpFunctionalExtensions;
using MediatR;
using Serilog;

namespace BarberBooking.API.CQRS.MasterProfile.Commands.Handlers
{
    public class DeleteMasterProfileHandler : IRequestHandler<DeleteMasterProfileCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMasterProfileRepository _masterProfileRepository;
        private readonly ILogger<CreateMasterProfileHandler> _logger;
        public DeleteMasterProfileHandler(IUnitOfWork unitOfWork, IMasterProfileRepository masterProfileRepository, ILogger<CreateMasterProfileHandler> logger)
        {
            _unitOfWork = unitOfWork;
            _masterProfileRepository = masterProfileRepository;
            _logger = logger;   
        }
        public async Task<Result<string>> Handle(DeleteMasterProfileCommand command, CancellationToken cancellationToken)
        {
            var masterProfile = await _masterProfileRepository.GetMasterProfileById(command.Id);
            if(masterProfile == null)
                return Result.Failure<string>("Профиль мастера не найден");
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.masterProfileRepository.DeleteMasterProfile(command.Id);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                _logger.LogError(ex.Message);
            }
            return "Успешно";
        }
    }
}