using System;
using System.Threading.Tasks;
using Sample.Exceptions;
using Sample.Observability;

namespace Sample.Services.Functions
{
    public class FunctionsRuntime : IFunctions
    {
        private readonly ICoreTelemetry telemetry;

        public FunctionsRuntime(ICoreTelemetry telemetry)
        {
            this.telemetry = Guard.ThrowIfNull(telemetry, nameof(telemetry));
        }

        public Task<string> GetAsync(string name)
        {
            using var span = this.telemetry.Start($"Functions-{nameof(FunctionsRuntime)}-{nameof(GetAsync)}");
            span.SetTag("tag-name", name);

            return Task.FromResult($"Hello, {name}. This HTTP triggered function executed successfully.");
        }

        public async Task<string> GetSecureAsync()
        {
            await Task.Delay(TimeSpan.FromSeconds(1));

            return "secure result";
        }
    }
}
