using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Contracts
{
    public interface ILoadingCityService
    {
        HashSet<string> CreateCityNames(IWebHostEnvironment env);
    }
}