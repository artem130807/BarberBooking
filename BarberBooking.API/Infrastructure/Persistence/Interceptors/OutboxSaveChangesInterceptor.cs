using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using BarberBooking.API.Domain.SalonStatisticDomain;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.EntityFrameworkCore.Migrations.Internal;

namespace BarberBooking.API.Infrastructure.Interceptors.Persistence
{
    public class OutboxSaveChangesInterceptor:SaveChangesInterceptor
    {
        public override ValueTask<InterceptionResult<int>> SavingChangesAsync(
        DbContextEventData eventData,
        InterceptionResult<int> result,
        CancellationToken cancellationToken = default)
        {
        var ctx = (BarberBookingDbContext)eventData.Context!;
        var entries = ctx.ChangeTracker.Entries<Models.SalonStatistic>()
                        .Where(e => e.State == EntityState.Added)
                        .ToList();

        foreach (var e in entries) {
            var ev = new CreateSalonStatisticEvent(e.Entity.Id, e.Entity.SalonId, e.Entity.CompletedAppointmentsCount, e.Entity.CancelledAppointmentsCount, e.Entity.SumPrice, e.Entity.Rating, e.Entity.RatingCount);
            var outbox = OutboxMessage.Create("SalonStatistic", e.Entity.Id.ToString(), nameof(CreateSalonStatisticEvent), 
            JsonSerializer.Serialize(ev));
            ctx.OutboxMessages.Add(outbox.Value);
        }
        return base.SavingChangesAsync(eventData, result, cancellationToken);
    }
    }
}