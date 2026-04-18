using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.FcmPushContracts;

public interface IFcmPushService
{
    Task SendAppointmentNotificationAsync(Messages message, CancellationToken cancellationToken = default);
}
