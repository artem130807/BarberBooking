using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Configurations
{
    public class EmailVerificationConfigurations : IEntityTypeConfiguration<EmailVerification>
    {
        public void Configure(EntityTypeBuilder<EmailVerification> builder)
        {
             builder.HasKey(x => x.Id);
            builder.ToTable("EmailVerification");
            builder.Property(x => x.Email);
            builder.Property(x => x.Code);
            builder.Property(x => x.CratedDate);
            builder.Property(x => x.ExpiresAt);
            builder.Property(x => x.LastSentAt);
            builder.Property(x => x.IsUsed);
        }
    }
}