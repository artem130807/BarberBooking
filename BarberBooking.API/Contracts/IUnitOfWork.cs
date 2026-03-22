using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.EmailContracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.MasterSubscriptionContracts;
using BarberBooking.API.Contracts.MessagesContracts;
using BarberBooking.API.Contracts.ReviewContracts;
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
        IEmailVerificationRepository emailVerificationRepository {get;}
        IMasterSubscriptionRepository masterSubscriptionRepository {get;}
        IEventStoreRepository eventStoreRepository {get;}
        IReviewRepository reviewRepository {get;}
        IUserRepository userRepository {get;}
        IMessagesRepository messagesRepository {get;}
        IUserRolesRepository userRolesRepository {get;}
        void BeginTransaction();
        void Commit();
        void RollBack();
    }
}