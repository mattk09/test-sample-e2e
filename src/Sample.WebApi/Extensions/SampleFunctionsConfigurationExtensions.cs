using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Sample.Exceptions;
using Sample.Services;
using Sample.Services.Functions;
using Sample.Services.Functions.Settings;
using Sample.Settings;

namespace Sample.Extensions
{
    public static class SampleFunctionsConfigurationExtensions
    {
        public static void AddSampleFunctions(this IServiceCollection services, SampleSettings settings)
        {
            Guard.ThrowIfNull(settings, nameof(settings));

            if (settings.Features.UseFunctionsSimulator)
            {
                services.AddSingleton<IFunctions, FunctionsSimulator>();
            }
            else
            {
                services.AddSingleton<AzureFunctionsSettings>(sp =>
                {
                    var configuration = sp.GetRequiredService<IConfiguration>();
                    return new AzureFunctionsSettings()
                    {
                        HostName = configuration.GetValue<string>("FunctionsAppHostName"),
                        Scheme = configuration.GetValue<string>("FunctionsAppHostNameScheme", "https"),
                        Code = configuration.GetValue<string>("function:helloworldsecure:default"),
                    };
                });

                services.AddSingleton<IFunctions, FunctionsHttp>();
                services.AddHttpClient<IFunctions, FunctionsHttp>();
            }
        }
    }
}
