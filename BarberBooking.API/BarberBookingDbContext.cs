using System;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using BarberBooking.API.Configurations;
using Microsoft.Extensions.Options;
using BarberBooking.API.Authorization;
using Microsoft.EntityFrameworkCore.Infrastructure.Internal;
using BarberBooking.API.Infrastructure.Persistence.Configurations;


namespace BarberBooking.API
{
    public class BarberBookingDbContext(DbContextOptions<BarberBookingDbContext> options, IOptions<AuthorizationOptions> authOptions): DbContext(options)
    {
        public DbSet<Salons> Salons {get; set;}
        public DbSet<Appointments>  Appointments{get; set;}
        public DbSet<MasterTimeSlot> MasterTimeSlots {get; set;}
        public DbSet<MasterProfile> MasterProfiles {get; set;}
        public DbSet<Users> Users {get; set;}
        public DbSet<Roles> Roles { get; set; }
        public DbSet<Review> Reviews {get; set;}
        public DbSet<Permissions> Permissions { get; set; }
        public DbSet<RolePermissionsEntity> RolePermissions { get; set; }
        public DbSet<MasterSubscription> MasterSubscriptions {get; set;}
        public DbSet<UserRoles> UserRoles { get; set; }
        public DbSet<Services> Sevices {get; set ;}
        public DbSet<WeeklyTemplate> WeeklyTemplates {get; set;}
        public DbSet<TemplateDay> TemplateDays {get; set;}
        public DbSet<EmailVerification> EmailVerifications {get; set;}
        public DbSet<EventStore> EventStores {get; set;}
        public DbSet<Messages> Messages {get; set;}
        public DbSet<SalonStatistic> SalonStatistics {get; set;}
        public DbSet<OutboxMessage> OutboxMessages {get; set;}
        public DbSet<MasterStatistic> MasterStatistics {get; set;}
        
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.ApplyConfiguration(new SalonsConfigurations());
            modelBuilder.ApplyConfiguration(new MasterProfileConfigurations());
            modelBuilder.ApplyConfiguration(new AppointmentsConfigurations());
            modelBuilder.ApplyConfiguration(new MasterTimeSlotConfigurations());
            modelBuilder.ApplyConfiguration(new UsersConfigurations());
            modelBuilder.ApplyConfiguration(new ServicesConfigurations());
            modelBuilder.ApplyConfiguration(new RolesConfigurations());
            modelBuilder.ApplyConfiguration(new PermissionsConfigurations());
            modelBuilder.ApplyConfiguration(new RolesPermissionsCofigurations(authOptions.Value));
            modelBuilder.ApplyConfiguration(new ReviewsConfigurations());
            modelBuilder.ApplyConfiguration(new TemplateDayConfigurations());
            modelBuilder.ApplyConfiguration(new WeeklyTemplateConfigurations());
            modelBuilder.ApplyConfiguration(new MasterSubscriptionConfigurations());
            modelBuilder.ApplyConfiguration(new MessagesConfigurations());
            modelBuilder.ApplyConfiguration(new SalonStatisticConfigurations());
            modelBuilder.ApplyConfiguration(new OutboxMessageConfigurations());
            modelBuilder.ApplyConfiguration(new MasterStatisticConfigurations());
            base.OnModelCreating(modelBuilder);
        }
        public void BeginTransaction()
        {
            Database.BeginTransaction();
            
        }
        public void CommitTransaction()
        {
            Database.CommitTransaction();
        }

        public void RollbackTransaction()
        {
            Database.RollbackTransaction();
        }
    }
}