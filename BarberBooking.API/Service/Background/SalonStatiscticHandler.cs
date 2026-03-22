using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Migrations;
using MediatR;

namespace BarberBooking.API.Service.Background
{
    public class SalonStatiscticHandler : ISalonStatiscticHandler
    {
        private readonly ISalonsRepository _salonsRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IAppointmentsRepository _appointmentsRepository;
        public SalonStatiscticHandler(ISalonsRepository salonsRepository, IUnitOfWork unitOfWork, IAppointmentsRepository appointmentsRepository)
        {
            _salonsRepository = salonsRepository;
            _unitOfWork = unitOfWork;
            _appointmentsRepository = appointmentsRepository;
        }
        public async Task Handle(CancellationToken cancellationToken)
        {
            var salons = await _salonsRepository.GetSalonsMounthStats();
            foreach(var salon in salons)
            {
                var appointments = await _appointmentsRepository.GetCountAppointmentsBySalonId(salon.Id);
            }
            
            
        }
    }
}