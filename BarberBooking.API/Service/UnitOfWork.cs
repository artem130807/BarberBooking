using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.EmailContracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.MasterSubscriptionContracts;
using BarberBooking.API.Contracts.MessagesContracts;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Contracts.TemplateDayContracts;
using BarberBooking.API.Contracts.WeeklyTemplateContracts;
using BarberBooking.API.Contracts.MasterServicesContracts;
using BarberBooking.API.Infrastructure.Persistence.Repositories;
using BarberBooking.API.Repositories;
using BarberBooking.API.Contracts.SalonsAdminContracts;
using BarberBooking.API.Contracts.SalonPhotosContracts;
using System.Data;
using BarberBooking.API.Contracts.ConversationsContracts;
using BarberBooking.API.Contracts.ConversationMessagesContracts;

namespace BarberBooking.API.Service
{
    public class UnitOfWork : IUnitOfWork
    {
        BarberBookingDbContext _dbContext;
        ILogger<MasterTimeSlotRepository> _logger;
        private IAppointmentsRepository _appointmentsRepository;
        private IMasterTimeSlotRepository _masterTimeSlotRepository;
        private IServicesRepository _servicesRepository;
        private IMasterServicesRepository _masterServicesRepository;
        private ISalonsRepository _salonsRepository;
        private IMasterProfileRepository _masterProfileRepository;
        private IEmailVerificationRepository _emailVerificationRepository;
        private IUserRepository _userRepository;
        private IMasterSubscriptionRepository _masterSubscriptionRepository;
        private IReviewRepository _reviewRepository;
        private IEventStoreRepository _eventStoreRepository;
        private IMessagesRepository _messageRepository;
        private IUserRolesRepository _userRolesRepository;
        private ISalonStatisticRepository _salonStatisticRepository;
        private IMasterStatisticRepository _masterStatisticRepository;
        private IWeeklyTemplateRepository _weeklyTemplateRepository;
        private ITemplateDayRepository _templateDayRepository;
        private ISalonsAdminRepository _salonsAdminRepository;
        private ISalonPhotosRepository _salonPhotosRepository;
        private IRefreshTokenRepository _refreshTokenRepository;
        private IConversationsRepository _conversationsRepository;
        private IConversationMessagesRepository _conversationMessagesRepository;
        public UnitOfWork(BarberBookingDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public IAppointmentsRepository appointmentsRepository
        {
            get {return _appointmentsRepository ??= new AppointmentsRepository(_dbContext);}
        }
        public ISalonsRepository salonsRepository
        {
            get {return _salonsRepository ??= new SalonsRepository(_dbContext);}
        }
        public IMasterTimeSlotRepository masterTimeSlotRepository
        {
             get {return _masterTimeSlotRepository ??= new MasterTimeSlotRepository(_dbContext, _logger);}
        }

        public IServicesRepository servicesRepository
        {
            get {return _servicesRepository ??= new ServicesRepository(_dbContext);}
        }

        public IMasterServicesRepository masterServicesRepository
        {
            get { return _masterServicesRepository ??= new MasterServicesRepository(_dbContext); }
        }

        public IMasterProfileRepository masterProfileRepository
        {
            get {return _masterProfileRepository ?? new MasterProfileRepository(_dbContext);}
        }

        public IEmailVerificationRepository emailVerificationRepository
        {
            get {return _emailVerificationRepository ?? new EmailVerificationRepository(_dbContext);}
        }

        public IUserRepository userRepository
        {
            get{return _userRepository ?? new UsersRepository(_dbContext);}
        }

        public IMasterSubscriptionRepository masterSubscriptionRepository
        {
            get{return _masterSubscriptionRepository ?? new MasterSubscriptionRepository(_dbContext);}
        }

        public IReviewRepository reviewRepository
        {
            get{return _reviewRepository ?? new ReviewRepository(_dbContext);}
        }

        public IEventStoreRepository eventStoreRepository
        {
            get{return _eventStoreRepository ?? new EventStoreRepository(_dbContext);}
        }
        public IMessagesRepository messagesRepository
        {
            get{return _messageRepository ?? new MessagesRepository(_dbContext);}
        }

        public IUserRolesRepository userRolesRepository
        {
            get{return _userRolesRepository ?? new UserRolesRepository(_dbContext);}
        }

        public ISalonStatisticRepository salonStatisticRepository
        {
            get{return _salonStatisticRepository ?? new SalonStatisticRepository(_dbContext);}
        }

        public IMasterStatisticRepository masterStatisticRepository
        {
            get { return _masterStatisticRepository ??= new MasterStatisticRepository(_dbContext); }
        }
        public IWeeklyTemplateRepository weeklyTemplateRepository
        {
            get {return _weeklyTemplateRepository ??= new WeeklyTemplateRepository(_dbContext);}
        }
        public ITemplateDayRepository templateDayRepository
        {
            get {return _templateDayRepository ??= new TemplateDayRepository(_dbContext);}
        }

        public ISalonsAdminRepository salonsAdminRepository
        {
            get {return _salonsAdminRepository ??= new SalonsAdminRepository(_dbContext);}
        }

        public ISalonPhotosRepository salonPhotosRepository  
        {
            get {return _salonPhotosRepository ??= new SalonPhotosRepository(_dbContext);}
        }

        public IRefreshTokenRepository refreshTokenRepository
        {
            get {return _refreshTokenRepository ??= new RefreshTokenRepository(_dbContext);}
        }

        public IConversationsRepository conversationsRepository
        {
            get {return _conversationsRepository ?? new ConversationsRepository(_dbContext);}
        }

        public IConversationMessagesRepository conversationMessagesRepository
        {
            get {return _conversationMessagesRepository ?? new ConversationMessagesRepository(_dbContext);}
        }

        public void BeginTransaction()
        {
            _dbContext.BeginTransaction();
        }

        public void Commit()
        {
            _dbContext.SaveChanges();
            _dbContext.CommitTransaction();
        }
        public void Dispose()
        {
            _dbContext.Dispose();
        }
        public void RollBack()
        {
            _dbContext.RollbackTransaction();
        }
    }
}