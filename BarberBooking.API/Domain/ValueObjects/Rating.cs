using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace BarberBooking.API.Domain.ValueObjects
{
    public class Rating : ValueObject
    {
        public decimal Value {get; private set;}

        [JsonConstructor]
        private Rating(decimal value)
        {
            Value = value;
        }
        private Rating(){}
        public static Rating Create(decimal value)
        {
            return new Rating(value);
        }
        protected override IEnumerable<object> GetEqualityComponents()
        {
            yield return Value;
        }
    }
}