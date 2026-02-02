using System;
using System.Collections.Generic;
using System.Linq;
using CSharpFunctionalExtensions;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace BarberBooking.API.Domain.ValueObjects
{
    public class Price:ValueObject
    {
        public decimal Value {get;}

        [JsonConstructor]
        private Price(decimal value)
        {
            Value = value;
        }
        private Price(){}
        public static Result<Price> Create(decimal value)
        {   
            if (value > 1_000_000)
                throw new InvalidOperationException("Цена слишком большая");
            if(value < 0)
                throw new InvalidOperationException("Цена не может быть отрицательной");
            return new Price(value);
        }
        public Price Add(Price other)
        {          
            return new Price(Value + other.Value);
        }
    
        public Price Multiply(decimal multiplier)
        {
            return new Price(Value * multiplier);
        }
        protected override IEnumerable<object> GetEqualityComponents()
        {
            yield return Value;
        }
    }
}