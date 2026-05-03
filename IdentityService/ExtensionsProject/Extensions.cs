using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace IdentityService.ExtensionsProject
{
    public static class Extensions
    {
        public static void AddDb(this IServiceCollection services, IConfiguration configuration)
        {
            services.AddDbContext<IdentityServiceDbContext>(o =>
            {
                o.UseNpgsql(configuration.GetConnectionString("DefaultConnection"));
            });
        }
    }
}