using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Infrastructure.Persistence.Configurations
{
    public class SalonsAdminConfigurations : IEntityTypeConfiguration<SalonsAdmin>
    {
        public void Configure(EntityTypeBuilder<SalonsAdmin> builder)
        {
            builder.ToTable("SalonsAdmin");
            builder.HasKey(x => x.Id);
            builder.HasOne(x => x.Salon).WithMany(x => x.SalonsAdmins).HasForeignKey(x => x.SalonId);
            builder.HasOne(x => x.User).WithMany(x => x.SalonsAdmins).HasForeignKey(x => x.UserId);
        }
    }
}