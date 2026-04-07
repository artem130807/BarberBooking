using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterServicesContracts;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Enums;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.AppointmentsFilter;
using BarberBooking.API.Models;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Service.Validator
{
    public class AppointmentCreationValidator : IAppointmentCreationValidator
    {
        private const int OverlapCheckPageSize = 5000;

        private readonly IMapper _mapper;
        private readonly IServicesRepository _servicesRepository;
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMasterServicesRepository _masterServicesRepository;

        public AppointmentCreationValidator(
            IMapper mapper,
            IServicesRepository servicesRepository,
            IMasterTimeSlotRepository masterTimeSlotRepository,
            IAppointmentsRepository appointmentsRepository,
            IMasterServicesRepository masterServicesRepository)
        {
            _mapper = mapper;
            _servicesRepository = servicesRepository;
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _appointmentsRepository = appointmentsRepository;
            _masterServicesRepository = masterServicesRepository;
        }

        public async Task<Result<ValidatedAppointmentCreationData>> ValidateAsync(
            DtoCreateAppointment dto,
            Guid userId,
            CancellationToken cancellationToken = default)
        {
            if (userId == Guid.Empty)
                return Result.Failure<ValidatedAppointmentCreationData>("Пользователь не авторизован");

            var service = await _servicesRepository.GetByIdAsync(dto.ServiceId);
            if (service == null)
                return Result.Failure<ValidatedAppointmentCreationData>("Услуги не существует");

            var masterOffersService =
                await _masterServicesRepository.ExistsAsync(dto.MasterId, dto.ServiceId);
            if (!masterOffersService)
                return Result.Failure<ValidatedAppointmentCreationData>(
                    "Выбранная услуга недоступна у этого мастера");

            var mapped = _mapper.Map<Appointments>(dto);
            var serviceDuration = TimeSpan.FromMinutes(service.DurationMinutes);
            if (serviceDuration <= TimeSpan.Zero)
                return Result.Failure<ValidatedAppointmentCreationData>("Некорректная длительность услуги");

            var sourceTimeSlot = await _masterTimeSlotRepository.GetByIdAsync(dto.TimeSlotId);
            if (sourceTimeSlot == null)
                return Result.Failure<ValidatedAppointmentCreationData>("Слот недоступен или устарел. Обновите список слотов.");

            if (sourceTimeSlot.MasterId != dto.MasterId)
                return Result.Failure<ValidatedAppointmentCreationData>("Слот не принадлежит выбранному мастеру.");

            var endTime = mapped.StartTime.Add(serviceDuration);
            var appointmentDateOnly = DateOnly.FromDateTime(dto.AppointmentDate);
            if (sourceTimeSlot.ScheduleDate != appointmentDateOnly)
                return Result.Failure<ValidatedAppointmentCreationData>("Слот не принадлежит выбранной дате.");

            if (mapped.StartTime < sourceTimeSlot.StartTime || endTime > sourceTimeSlot.EndTime)
                return Result.Failure<ValidatedAppointmentCreationData>("Время записи выходит за пределы выбранного слота.");

            var filter = new FilterAppointments();
            var pageParams = new PageParams { Page = 1, PageSize = OverlapCheckPageSize };
            var masterAppointmentsPage = await _appointmentsRepository.GetAppointmentsByMasterId(
                dto.MasterId, filter, pageParams);

            var hasOverlap = masterAppointmentsPage.Data.Any(a =>
                a.Status != AppointmentStatusEnum.Cancelled &&
                DateOnly.FromDateTime(a.AppointmentDate) == appointmentDateOnly &&
                mapped.StartTime < a.EndTime &&
                a.StartTime < endTime);

            if (hasOverlap)
                return Result.Failure<ValidatedAppointmentCreationData>("Выбранный интервал уже занят. Обновите доступные слоты.");

            return Result.Success(new ValidatedAppointmentCreationData(mapped, endTime));
        }
    }
}
