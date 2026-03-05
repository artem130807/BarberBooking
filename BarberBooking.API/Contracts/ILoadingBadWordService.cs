using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Contracts
{
    public interface ILoadingBadWordService
    {
        HashSet<string> CreateBadWord(IWebHostEnvironment env);
    }
}