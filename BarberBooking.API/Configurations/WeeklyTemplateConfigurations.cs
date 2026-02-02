using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace BarberBooking.API.Configurations
{
    public class WeeklyTemplateConfigurations : IEntityTypeConfiguration<WeeklyTemplate>
    {
        public void Configure(EntityTypeBuilder<WeeklyTemplate> builder)
        {
             builder.ToTable("WeeklyTemplates");
        
            builder.HasKey(x => x.Id);
            
            builder.Property(x => x.Name)
                .IsRequired()
                .HasMaxLength(200);
                
            builder.HasOne(x => x.MasterProfile)
                .WithMany()
                .HasForeignKey(x => x.MasterId)
                .OnDelete(DeleteBehavior.Cascade);
                
            builder.HasMany(x => x.TemplateDays)
                .WithOne(x => x.WeeklyTemplate)
                .HasForeignKey(x => x.TemplateId)
                .OnDelete(DeleteBehavior.Cascade);
                
            builder.Property(x => x.CreatedAt)
                .IsRequired();
        }
    }
}