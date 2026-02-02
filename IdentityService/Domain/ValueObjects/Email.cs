using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;
using IdentityService.Domain.Common;
using Microsoft.AspNetCore.Http.HttpResults;

namespace IdentityService.Domain.ValueObjects
{
    public class Email : Common.ValueObject
    {
        public string Value {get;}
        [JsonConstructor]
        private Email(string value)
        {
            Value = value;
        }
        private Email(){}
        public  static Result<Email> CreateEmail(string value)
        {
            if (string.IsNullOrEmpty(value) || string.IsNullOrWhiteSpace(value))
                return Result.Failure<Email>("Email не может быть пустым");
            if (!new System.ComponentModel.DataAnnotations.EmailAddressAttribute().IsValid(value)) 
                return Result.Failure<Email>("Неверный формат email"); 
            if (!value.Contains("@"))
                return Result.Failure<Email>("Неверный формат email");
                
            return Result.Success(new Email(value));
        }
        protected override IEnumerable<object> GetEqualityComponents()
        {
            yield return Value;
        }
    }
}