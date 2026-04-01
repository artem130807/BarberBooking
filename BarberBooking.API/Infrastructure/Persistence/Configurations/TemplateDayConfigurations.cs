using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Configurations
{
    public class TemplateDayConfigurations : IEntityTypeConfiguration<TemplateDay>
    {
        public void Configure(EntityTypeBuilder<TemplateDay> builder)
        {
            builder.ToTable("TemplateDays");
        
            builder.HasKey(x => x.Id);
            
            builder.Property(x => x.DayOfWeek)
                .IsRequired();
                
            builder.HasOne(x => x.WeeklyTemplate)
                .WithMany(x => x.TemplateDays)
                .HasForeignKey(x => x.TemplateId)
                .OnDelete(DeleteBehavior.Cascade);
                
            builder.HasIndex(x => new { x.TemplateId, x.DayOfWeek })
                .IsUnique();
        }
    }
}