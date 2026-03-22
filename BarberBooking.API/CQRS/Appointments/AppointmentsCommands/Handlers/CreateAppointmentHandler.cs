using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Models;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.AppointmentsCommands.Handlers
{
    public class CreateAppointmentHandler : IRequestHandler<CreateAppointmentCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMapper _mapper;
        private readonly IServicesRepository _servicesRepository;
        private readonly IUserContext _userContext;
        public CreateAppointmentHandler(IUnitOfWork unitOfWork, IAppointmentsRepository appointmentsRepository, IMapper mapper, IServicesRepository servicesRepository, IUserContext userContext)
        {
            _unitOfWork = unitOfWork;
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;
            _servicesRepository = servicesRepository;     
            _userContext = userContext;     
        }
        public async Task<Result<string>> Handle(CreateAppointmentCommand command, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            if (userId == Guid.Empty)
                return Result.Failure<string>("Пользователь не авторизован");

            var service = await _servicesRepository.GetByIdAsync(command.DtoCreateAppointment.ServiceId);
            if(service == null)
                return Result.Failure<string>("Услуги не существует");

            var dtoAppointmet = _mapper.Map<Models.Appointments>(command.DtoCreateAppointment);
            var serviceDuration = TimeSpan.FromMinutes(service.DurationMinutes);
            if (serviceDuration <= TimeSpan.Zero)
                return Result.Failure<string>("Некорректная длительность услуги");

            var sourceTimeSlot = await _unitOfWork.masterTimeSlotRepository
                .GetByIdAsync(command.DtoCreateAppointment.TimeSlotId);
            if (sourceTimeSlot == null)
                return Result.Failure<string>("Слот недоступен или устарел. Обновите список слотов.");

            if (sourceTimeSlot.MasterId != command.DtoCreateAppointment.MasterId)
                return Result.Failure<string>("Слот не принадлежит выбранному мастеру.");

            var endTime = dtoAppointmet.StartTime.Add(serviceDuration);
            var appointmentDateOnly = DateOnly.FromDateTime(command.DtoCreateAppointment.AppointmentDate);
            if (sourceTimeSlot.ScheduleDate != appointmentDateOnly)
                return Result.Failure<string>("Слот не принадлежит выбранной дате.");

            if (dtoAppointmet.StartTime < sourceTimeSlot.StartTime || endTime > sourceTimeSlot.EndTime)
                return Result.Failure<string>("Время записи выходит за пределы выбранного слота.");

            var masterAppointmentsOnDate = await _appointmentsRepository
                .GetAppointmentsByMasterId(command.DtoCreateAppointment.MasterId);

            var hasOverlap = masterAppointmentsOnDate.Any(a =>
                DateOnly.FromDateTime(a.AppointmentDate) == appointmentDateOnly &&
                dtoAppointmet.StartTime < a.EndTime &&
                a.StartTime < endTime);

            if (hasOverlap)
                return Result.Failure<string>("Выбранный интервал уже занят. Обновите доступные слоты.");

            var appointment = Models.Appointments.Create(dtoAppointmet.SalonId,dtoAppointmet.MasterId, userId,
                dtoAppointmet.ServiceId, dtoAppointmet.TimeSlotId, dtoAppointmet.StartTime,
                dtoAppointmet.ClientNotes, endTime, dtoAppointmet.AppointmentDate);
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.appointmentsRepository.CreateAsync(appointment);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                var detailedMessage = ex.InnerException?.Message ?? ex.Message;
                throw new InvalidOperationException($"Ошибка сохранения записи: {detailedMessage}", ex);
            }
            // var result =  _mapper.Map<DtoCreateAppointmentInfo>(appointment);
            return Result.Success("Успешно");
        }
    }
}