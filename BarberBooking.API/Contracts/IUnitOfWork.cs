using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.SalonsContracts;

namespace BarberBooking.API.Contracts
{
    public interface IUnitOfWork:IDisposable
    {
        IAppointmentsRepository appointmentsRepository {get;}
        IMasterTimeSlotRepository masterTimeSlotRepository {get;}
        IServicesRepository servicesRepository {get;}
        ISalonsRepository salonsRepository {get;}
        IMasterProfileRepository masterProfileRepository {get;}
        void BeginTransaction();
        void Commit();
        void RollBack();
    }
}