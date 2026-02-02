using System;
using System.Collections.Generic;
using System.Linq;
using CSharpFunctionalExtensions;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using System.Text.RegularExpressions;

namespace BarberBooking.API.Domain.ValueObjects
{
    public class Address:ValueObject
    {
        public string City {get;}
        public string Street {get;}
        public string HouseNumber{get;}
        public string Apartment {get;}
        
        [JsonConstructor]
        private Address(string city, string street, string housenumber, string apartment)
        {
            City = city.Trim();
            Street = street.Trim();
            HouseNumber = housenumber.Trim();
            Apartment = apartment?.Trim();
        }
        private Address(){}
        public static Result<Address> Create(string city, string street, string housenumber, string apartment)
        {
            if(string.IsNullOrWhiteSpace(city))
                return Result.Failure<Address>("Город не может быть пустым");
            if(string.IsNullOrWhiteSpace(street))
                return Result.Failure<Address>("Улица не может быть пустой ");
            if(string.IsNullOrWhiteSpace(housenumber))
                return Result.Failure<Address>("Номер дома не может быть пустым");
            if (city.Length > 100)
                return Result.Failure<Address>("Название города слишком длинное");
            if (street.Length > 200)
                return Result.Failure<Address>("Название улицы слишком длинное");
            if (!Regex.IsMatch(housenumber, @"^[\dА-Яа-я/\-]+$"))
                return Result.Failure<Address>("Некорректный формат номера дома");
            return new Address(city.Trim(), street.Trim(), housenumber.Trim(), apartment?.Trim());
        }
        protected override IEnumerable<object> GetEqualityComponents()
        {
            yield return City;
            yield return Street;
            yield return HouseNumber;
            yield return Apartment ?? string.Empty;
        }
    }
}