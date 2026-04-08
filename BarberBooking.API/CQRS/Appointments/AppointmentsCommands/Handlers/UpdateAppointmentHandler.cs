using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoAppointments;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.AppointmentsCommands.Handlers
{
    public class UpdateAppointmentHandler:IRequestHandler<UpdateAppointmentCommand, Result<DtoClientAppointmentInfo>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMapper _mapper;
        private readonly IUpdateAppointmentService _updateAppointmentService;
        private readonly IUserContext _userContext;
        public UpdateAppointmentHandler(
            IUnitOfWork unitOfWork,
            IAppointmentsRepository appointmentsRepository,
            IMapper mapper,
            IUpdateAppointmentService updateAppointmentService,
            IUserContext userContext)
        {
            _unitOfWork = unitOfWork;
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;
            _updateAppointmentService = updateAppointmentService;
            _userContext = userContext;
        }

        public async Task<Result<DtoClientAppointmentInfo>> Handle(UpdateAppointmentCommand command, CancellationToken cancellationToken)
        {
            var appointment = await _appointmentsRepository.GetByIdAsync(command.Id);
            if(appointment == null)
                return Result.Failure<DtoClientAppointmentInfo>("Такой записи не существует");
            var userId = _userContext.UserId;
            var isClient = appointment.ClientId == userId;
            var isMaster = appointment.Master.UserId == userId;
            if (!isClient && !isMaster)
                return Result.Failure<DtoClientAppointmentInfo>("Нет доступа");
            try
            {
                _unitOfWork.BeginTransaction();
                await _updateAppointmentService.UpdateAsync(appointment, command.dtoUpdateAppointment);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<DtoClientAppointmentInfo>(ex.Message);
            }
            return Result.Success(_mapper.Map<DtoClientAppointmentInfo>(appointment));
        }
    }
}