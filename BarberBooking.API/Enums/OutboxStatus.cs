using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Enums
{
    public enum OutboxStatus
    {
        Pending = 0,
        Processed = 1,
        Failed = 2,
        Dead = 3,
    }
}