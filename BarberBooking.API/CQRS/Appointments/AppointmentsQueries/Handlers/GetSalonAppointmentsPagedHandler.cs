using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonsAdminContracts;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Appointments.AppointmentsQueries.Handlers
{
    public class GetSalonAppointmentsPagedHandler : IRequestHandler<GetSalonAppointmentsPagedQuery, Result<PagedResult<DtoSalonAppointmentAdmin>>>
    {
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMapper _mapper;
        private readonly AdminSalonAccess _adminSalonAccess;

        public GetSalonAppointmentsPagedHandler(IAppointmentsRepository appointmentsRepository, IMapper mapper, AdminSalonAccess adminSalonAccess)
        {
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;
            _adminSalonAccess = adminSalonAccess;
        }

        public async Task<Result<PagedResult<DtoSalonAppointmentAdmin>>> Handle(GetSalonAppointmentsPagedQuery query, CancellationToken cancellationToken)
        {
            var access = await _adminSalonAccess.RequireSalonAsync(query.salonId, cancellationToken);
            if (access.IsFailure)
                return Result.Failure<PagedResult<DtoSalonAppointmentAdmin>>(access.Error);
            var appointments = await _appointmentsRepository.GetAllAppointments(query.salonId, query.filter, query.pageParams);
            if (appointments.Count == 0)
                return Result.Failure<PagedResult<DtoSalonAppointmentAdmin>>("Список записей пуст");
            var result = _mapper.Map<PagedResult<DtoSalonAppointmentAdmin>>(appointments);
            return Result.Success(result);
        }
    }
}
