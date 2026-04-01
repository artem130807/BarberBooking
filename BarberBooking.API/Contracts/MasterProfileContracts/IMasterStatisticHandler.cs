using System.Threading;
using System.Threading.Tasks;

namespace BarberBooking.API.Contracts.MasterProfileContracts
{
    public interface IMasterStatisticHandler
    {
        Task Handle(CancellationToken cancellationToken = default);
    }
}
