using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Enums;
using BarberBooking.API.Filters.AppointmentsFilter;
using BarberBooking.API.Models;

namespace BarberBooking.API.ExtensionsProject
{
    public static class AppointmentsExtennsions
    {
        public static IQueryable<Appointments> AppointmentFilter(this IQueryable<Appointments> query, FilterAppointments filter)
        {
            if (filter.AppointmentFrom.HasValue)
            {
                var from = filter.AppointmentFrom.Value.Date;
                query = query.Where(x => x.AppointmentDate >= from);
            }

            if (filter.AppointmentTo.HasValue)
            {
                var toExclusive = filter.AppointmentTo.Value.Date.AddDays(1);
                query = query.Where(x => x.AppointmentDate < toExclusive);
            }

            if (filter.from.HasValue)
                query = query.Where(x => x.CreatedAt >= filter.from.Value);

            if (filter.to.HasValue)
                query = query.Where(x => x.CreatedAt <= filter.to.Value);

            if (filter.Confirmed.HasValue)
                query = query.Where(x => x.Status == AppointmentStatusEnum.Confirmed);

            if (filter.Completed.HasValue)
                query = query.Where(x => x.Status == AppointmentStatusEnum.Completed);

            if (filter.Cancelled.HasValue)
                query = query.Where(x => x.Status == AppointmentStatusEnum.Cancelled);

            if (filter.ThisWeek == true)
            {
                var today = DateTime.Today;
                var daysFromMonday = (7 + (today.DayOfWeek - DayOfWeek.Monday)) % 7;
                var weekStart = today.AddDays(-daysFromMonday).Date;
                var weekEndExclusive = weekStart.AddDays(7);
                query = query.Where(x => x.CreatedAt >= weekStart && x.CreatedAt < weekEndExclusive);
            }

            if (filter.ThisDay == true)
            {
                var start = DateTime.Today;
                var end = start.AddDays(1);
                query = query.Where(x => x.CreatedAt >= start && x.CreatedAt < end);
            }
            if (filter.ThisMounth == true)
            {
                var start = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
                var end = start.AddMonths(1);
                query = query.Where(x => x.CreatedAt >= start && x.CreatedAt < end);
            }
                           
            query = query
                .OrderByDescending(x => x.AppointmentDate)
                .ThenByDescending(x => x.StartTime);

            return query;
        }
    }
}