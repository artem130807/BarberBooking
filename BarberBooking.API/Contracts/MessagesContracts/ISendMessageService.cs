using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using Confluent.Kafka;

namespace BarberBooking.API.Contracts.MessagesContracts
{
    public interface ISendMessageService
    {
        Task Send(Messages message);
    }
}