using System;
using System.Net.Http;
using System.Threading.Tasks;
using Sample.Exceptions;
using Sample.Observability;
using Sample.Services.Functions.Settings;

namespace Sample.Services.Functions
{
    public class FunctionsHttp : IFunctions
    {
        private readonly ICoreTelemetry telemetry;
        private readonly HttpClient httpClient;
        private readonly AzureFunctionsSettings settings;
        private readonly string uriScheme;
        private readonly string hostName;
        private readonly string code;

        public FunctionsHttp(ICoreTelemetry telemetry, HttpClient httpClient, AzureFunctionsSettings settings)
        {
            this.telemetry = Guard.ThrowIfNull(telemetry, nameof(telemetry));
            this.httpClient = Guard.ThrowIfNull(httpClient, nameof(httpClient));
            this.settings = Guard.ThrowIfNull(settings, nameof(settings));

            this.hostName = this.settings.HostName;
            this.uriScheme = this.settings.Scheme;
            this.code = this.settings.Code;
        }

        public async Task<string> GetAsync(string name)
        {
            string uriTarget = $"{this.uriScheme}://{this.hostName}/api/";
            using var span = this.telemetry.Start($"Functions-{nameof(FunctionsHttp)}-{nameof(GetAsync)}");
            span.SetTag("tag-target-uri", uriTarget);
            span.SetBaggage("span-origin", "sample-webapi");

            httpClient.BaseAddress = new Uri(uriTarget);

            var response = await this.httpClient.GetAsync(new Uri($"HelloWorld?name={name}", UriKind.Relative));
            response.EnsureSuccessStatusCode();

            return await response.Content.ReadAsStringAsync();
        }

        public async Task<string> GetSecureAsync()
        {
            httpClient.BaseAddress = new Uri($"{this.uriScheme}://{this.hostName}/api/");

            var response = await this.httpClient.GetAsync(new Uri($"HelloWorldSecure?code={this.code}", UriKind.Relative));
            response.EnsureSuccessStatusCode();

            return await response.Content.ReadAsStringAsync();
        }
    }
}
