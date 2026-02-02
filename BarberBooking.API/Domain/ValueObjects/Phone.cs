using System;
using System.Collections.Generic;
using System.Linq;
using CSharpFunctionalExtensions;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using System.Text.RegularExpressions;

namespace BarberBooking.API.Domain.ValueObjects
{
    public class PhoneNumber:ValueObject
    {
        public string Number {get;}

        [JsonConstructor]
        private PhoneNumber(string number)
        {
            Number = number;
        }
        private const string phoneRegex = @"^(\+7|7|8)?[\s\-]?\(?\d{3}\)?[\s\-]?\d{3}[\s\-]?\d{2}[\s\-]?\d{2}$";
        private PhoneNumber(){}
        public static Result<PhoneNumber> Create(string number)
        {
            if(string.IsNullOrWhiteSpace(number))
                return Result.Failure<PhoneNumber>("Ошибка");
            if(Regex.IsMatch(number, phoneRegex) == false)
                return Result.Failure<PhoneNumber>("Номер не соостветстует стандарту");
            return new PhoneNumber(number);
        }
        protected override IEnumerable<object> GetEqualityComponents()
        {
            yield return Number;
        }
    }
}