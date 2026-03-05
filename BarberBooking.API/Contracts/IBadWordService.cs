using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Contracts
{
    public interface IBadWordService
    {
        bool IsTextValid(string text);
    }
}