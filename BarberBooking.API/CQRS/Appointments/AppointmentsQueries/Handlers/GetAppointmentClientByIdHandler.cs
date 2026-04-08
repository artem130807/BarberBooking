using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoAppointments;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.AppointmentsQueries.Handlers
{
    public class GetAppointmentClientByIdHandler : IRequestHandler<AppointmentsQueries.GetAppointmentClientByIdHandler, Result<DtoClientAppointmentInfo>>
    {
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMapper _mapper;
        private readonly IUserContext _userContext;
        public GetAppointmentClientByIdHandler(
            IAppointmentsRepository appointmentsRepository,
            IMapper mapper,
            IUserContext userContext)
        {
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;
            _userContext = userContext;
        }
        public async Task<Result<DtoClientAppointmentInfo>> Handle(AppointmentsQueries.GetAppointmentClientByIdHandler query, CancellationToken cancellationToken)
        {
            if (!_userContext.IsAuthenticated || _userContext.UserId == Guid.Empty)
                return Result.Failure<DtoClientAppointmentInfo>("Требуется авторизация");
            var appointment = await _appointmentsRepository.GetByIdAsync(query.Id);
            if(appointment == null)
                return Result.Failure<DtoClientAppointmentInfo>("Запись не найдена");
            if (appointment.ClientId != _userContext.UserId)
                return Result.Failure<DtoClientAppointmentInfo>("Нет доступа");
            var result = _mapper.Map<DtoClientAppointmentInfo>(appointment);
            return Result.Success(result);
        }
    }
}