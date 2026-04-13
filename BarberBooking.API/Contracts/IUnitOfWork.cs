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
using BarberBooking.API.Contracts.TemplateDayContracts;
using BarberBooking.API.Contracts.WeeklyTemplateContracts;
using BarberBooking.API.Contracts.MasterServicesContracts;
using BarberBooking.API.Contracts.SalonsAdminContracts;
using BarberBooking.API.Contracts.SalonPhotosContracts;

namespace BarberBooking.API.Contracts
{
    public interface IUnitOfWork:IDisposable
    {
        IAppointmentsRepository appointmentsRepository {get;}
        IMasterTimeSlotRepository masterTimeSlotRepository {get;}
        IServicesRepository servicesRepository {get;}
        IMasterServicesRepository masterServicesRepository { get; }
        ISalonsRepository salonsRepository {get;}
        IMasterProfileRepository masterProfileRepository {get;}
        IEmailVerificationRepository emailVerificationRepository {get;}
        IMasterSubscriptionRepository masterSubscriptionRepository {get;}
        IEventStoreRepository eventStoreRepository {get;}
        IReviewRepository reviewRepository {get;}
        IUserRepository userRepository {get;}
        IMessagesRepository messagesRepository {get;}
        IUserRolesRepository userRolesRepository {get;}
        ISalonStatisticRepository salonStatisticRepository {get;}
        IMasterStatisticRepository masterStatisticRepository {get;}
        IWeeklyTemplateRepository weeklyTemplateRepository {get;}
        ITemplateDayRepository templateDayRepository {get;}
        // ISalonsAdminRepository salonsAdminRepository {get;}
        void BeginTransaction();
        void Commit();
        void RollBack();
    }
}