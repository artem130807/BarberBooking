using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.EmailContracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.MasterSubscriptionContracts;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Repositories;

namespace BarberBooking.API.Service
{
    public class UnitOfWork : IUnitOfWork
    {
        BarberBookingDbContext _dbContext;
        ILogger<MasterTimeSlotRepository> _logger;
        private IAppointmentsRepository _appointmentsRepository;
        private IMasterTimeSlotRepository _masterTimeSlotRepository;
        private IServicesRepository _servicesRepository;
        private ISalonsRepository _salonsRepository;
        private IMasterProfileRepository _masterProfileRepository;
        private IEmailVerificationRepository _emailVerificationRepository;
        private IUserRepository _userRepository;
        private IMasterSubscriptionRepository _masterSubscriptionRepository;
        private IReviewRepository _reviewRepository;
        private IEventStoreRepository _eventStoreRepository;
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