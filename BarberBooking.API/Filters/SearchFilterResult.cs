using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;

namespace BarberBooking.API.Filters
{
    public class SearchFilterResult
    {
        public List<Salons> Data { get; }
        public SearchFilterResult(List<Salons> data)
        {
            Data = data;
        }
    }
}