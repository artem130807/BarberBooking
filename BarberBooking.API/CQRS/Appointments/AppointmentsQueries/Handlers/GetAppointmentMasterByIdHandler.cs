using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Dto.DtoAppointments;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Appointments.AppointmentsQueries.Handlers
{
    public class GetAppointmentMasterByIdHandler : IRequestHandler<GetAppointmentMasterByIdQuery, Result<DtoMasterAppointmentInfo>>
    {
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMapper _mapper;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;

        public GetAppointmentMasterByIdHandler(
            IAppointmentsRepository appointmentsRepository,
            IMapper mapper,
            IUserContext userContext,
            IMasterProfileRepository masterProfileRepository)
        {
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
        }

        public async Task<Result<DtoMasterAppointmentInfo>> Handle(GetAppointmentMasterByIdQuery query, CancellationToken cancellationToken)
        {
            var master = await _masterProfileRepository.GetMasterProfileByUserId(_userContext.UserId);
            if (master == null)
                return Result.Failure<DtoMasterAppointmentInfo>("Доступно только мастеру");

            var appointment = await _appointmentsRepository.GetByIdAsync(query.Id);
            if(appointment == null)
                return Result.Failure<DtoMasterAppointmentInfo>("Запись не найдена");
            if (appointment.MasterId != master.Id)
                return Result.Failure<DtoMasterAppointmentInfo>("Нет доступа к этой записи");
            var result = _mapper.Map<DtoMasterAppointmentInfo>(appointment);
            return Result.Success(result);
        }
    }
}