using System.Threading;
using System.Threading.Tasks;

namespace BarberBooking.API.Contracts.SalonsContracts
{
    public interface ISalonStatiscticHandler
    {
        Task Handle(CancellationToken cancellationToken = default);
    }
}
