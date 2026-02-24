using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;

namespace BarberBooking.API.Domain
{
    public abstract class AggregateRoot
    {
        public Guid Id {get; protected set;}
        public int Version {get; private set;}
        private readonly List<DomainEvent> _changes = new ();
        public IEnumerable<DomainEvent> GetUncommittedChanges() => _changes.AsReadOnly();
        public void MarkChangesAsCommitted() => _changes.Clear();

        protected void ApplyChange(DomainEvent @event, bool isNew = true)
        {
            var method = GetType().GetMethod("Apply", 
            BindingFlags.Instance | BindingFlags.NonPublic,
            null,
            [@event.GetType()],
            null);
            if (method != null)
            {
                method.Invoke(this, [@event]);
            }
            if (isNew)
            {
                Version++;
                @event.UpdateVersion(Version);
                _changes.Add(@event);
            }
        }
        public void LoadFromHistory(IEnumerable<DomainEvent> history)
        {
            foreach (var @event in history.OrderBy(e => e.Version))
            {
                ApplyChange(@event, isNew: false);
            }
        }
    }
}