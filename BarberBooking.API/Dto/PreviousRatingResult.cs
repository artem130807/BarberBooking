using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto
{
    public class PreviousRatingResult
    {
        public decimal PreviousRating {get; set;}
        public int PreviousRatingCount {get; set;}
        public PreviousRatingResult(decimal previousRating, int previousRatingCount)
        {
            PreviousRating = previousRating;
            PreviousRatingCount = previousRatingCount;
        }
    }
}