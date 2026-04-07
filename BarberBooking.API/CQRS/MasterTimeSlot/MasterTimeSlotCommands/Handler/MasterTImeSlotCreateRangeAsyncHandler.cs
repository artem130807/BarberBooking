using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using BarberBooking.API.Models;
using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.AspNetCore.Mvc.ModelBinding.Binders;

namespace BarberBooking.API.CQRS.MasterTimeSlotCommands.Handler
{
    public class MasterTimeSlotCreateRangeAsyncHandler : IRequestHandler<MasterTimeSlotCreateRangeAsyncCommand, Result<List<DtoMasterTimeSlotInfo>>>
    {
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly IMapper _mapper;
        private readonly IUnitOfWork _unitOfWork;
        public MasterTimeSlotCreateRangeAsyncHandler(IMasterTimeSlotRepository masterTimeSlotRepository, IMapper mapper, IUnitOfWork unitOfWork)
        {
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _mapper = mapper;
            _unitOfWork = unitOfWork;
        }
        public async Task<Result<List<DtoMasterTimeSlotInfo>>> Handle(MasterTimeSlotCreateRangeAsyncCommand command, CancellationToken cancellationToken)
        {
            var timeSlots = _mapper.Map<List<Models.MasterTimeSlot>>(command.dtoCreateMasterTimeSlot);
            if(timeSlots.Count == 0)
                return Result.Failure<List<DtoMasterTimeSlotInfo>>("Список оказался пуст"); 
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.masterTimeSlotRepository.CreateRangeAsync(timeSlots);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                throw new InvalidOperationException(ex.Message);
            }
            var result= _mapper.Map<List<DtoMasterTimeSlotInfo>>(timeSlots);
            return Result.Success(result);
        }
    }
}