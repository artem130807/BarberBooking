using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Infrastructure.Persistence.Configurations
{
    public class MasterServicesConfigurations : IEntityTypeConfiguration<MasterServices>
    {
        public void Configure(EntityTypeBuilder<MasterServices> builder)
        {
            builder.ToTable("MasterServices");
            builder.HasKey(x => x.Id);
            builder.HasOne(x => x.MasterProfile).WithMany(x => x.MasterServices).HasForeignKey(x => x.MasterProfileId);
            builder.HasOne(x => x.Service).WithMany(x => x.MasterServices).HasForeignKey(x => x.ServiceId);
        }
    }
}