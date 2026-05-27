using System;
using System.Linq;
using BarberBooking.API.Enums;
using BarberBooking.API.Filters.AppointmentsFilter;
using BarberBooking.API.Models;

namespace BarberBooking.API.ExtensionsProject
{
    public static class AppointmentsExtennsions
    {
        /// <summary>
        /// Npgsql: параметры для timestamptz должны быть <see cref="DateTimeKind.Utc"/>.
        /// </summary>
        private static DateTime UtcDate(DateTime dateTime)
        {
            var date = dateTime.Date;
            return date.Kind switch
            {
                DateTimeKind.Utc => date,
                DateTimeKind.Local => date.ToUniversalTime(),
                _ => DateTime.SpecifyKind(date, DateTimeKind.Utc),
            };
        }

        private static DateTime ToUtcForPostgres(DateTime value) =>
            value.Kind switch
            {
                DateTimeKind.Utc => value,
                DateTimeKind.Local => value.ToUniversalTime(),
                _ => DateTime.SpecifyKind(value, DateTimeKind.Utc),
            };

        private static DateTime UtcDayExclusiveEndAfterLastInclusiveDay(DateTime lastDayInclusive)
            => UtcDate(lastDayInclusive).AddDays(1);

        public static IQueryable<Appointments> AppointmentFilter(this IQueryable<Appointments> query, FilterAppointments filter)
        {
            if (filter.AppointmentFrom.HasValue)
            {
                var from = UtcDate(filter.AppointmentFrom.Value);
                query = query.Where(x => x.AppointmentDate >= from);
            }

            if (filter.AppointmentTo.HasValue)
            {
                var toExclusive = UtcDayExclusiveEndAfterLastInclusiveDay(filter.AppointmentTo.Value);
                query = query.Where(x => x.AppointmentDate < toExclusive);
            }

            if (filter.from.HasValue)
                query = query.Where(x => x.CreatedAt >= ToUtcForPostgres(filter.from.Value));

            if (filter.to.HasValue)
                query = query.Where(x => x.CreatedAt <= ToUtcForPostgres(filter.to.Value));

            if (filter.Confirmed == true)
                query = query.Where(x => x.Status == AppointmentStatusEnum.Confirmed);

            if (filter.Completed == true)
                query = query.Where(x => x.Status == AppointmentStatusEnum.Completed);

            if (filter.Cancelled == true)
                query = query.Where(x => x.Status == AppointmentStatusEnum.Cancelled);

            if (filter.ThisWeek == true)
            {
                var todayUtc = DateTime.UtcNow.Date;
                var daysFromMonday = (7 + (todayUtc.DayOfWeek - DayOfWeek.Monday)) % 7;
                var weekStart = DateTime.SpecifyKind(todayUtc.AddDays(-daysFromMonday), DateTimeKind.Utc);
                var weekEndExclusive = weekStart.AddDays(7);
                query = query.Where(x => x.CreatedAt >= weekStart && x.CreatedAt < weekEndExclusive);
            }

            if (filter.ThisDay == true)
            {
                var start = DateTime.SpecifyKind(DateTime.UtcNow.Date, DateTimeKind.Utc);
                var end = start.AddDays(1);
                query = query.Where(x => x.CreatedAt >= start && x.CreatedAt < end);
            }

            if (filter.ThisMounth == true)
            {
                var nowUtc = DateTime.SpecifyKind(DateTime.UtcNow.Date, DateTimeKind.Utc);
                var start = new DateTime(nowUtc.Year, nowUtc.Month, 1, 0, 0, 0, DateTimeKind.Utc);
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
