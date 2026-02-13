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
        public GetAppointmentClientByIdHandler(IAppointmentsRepository appointmentsRepository, IMapper mapper)
        {
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;
        }
        public async Task<Result<DtoClientAppointmentInfo>> Handle(AppointmentsQueries.GetAppointmentClientByIdHandler query, CancellationToken cancellationToken)
        {
            var appointment = await _appointmentsRepository.GetByIdAsync(query.Id);
            if(appointment == null)
                return Result.Failure<DtoClientAppointmentInfo>("Запись не найдена");
            var result = _mapper.Map<DtoClientAppointmentInfo>(appointment);
            return Result.Success(result);
        }
    }
}