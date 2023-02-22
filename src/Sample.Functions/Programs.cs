using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Sample.Observability;
using Sample.Observability.Settings;
using Sample.Services;
using Sample.Services.Functions;

await new HostBuilder()
    .ConfigureFunctionsWorkerDefaults(builder =>
    {
        // builder.AddApplicationInsights()
        //       .AddApplicationInsightsLogger();
        builder.UseMiddleware<FunctionActivityRootMiddleware>();
    })
    .ConfigureServices(services =>
    {
        var configuration = services.BuildServiceProvider().GetRequiredService<IConfiguration>();
        string telemetryProvider = configuration.GetValue<string>("TelemetryProvider", "None") ?? "None";

        services.AddLogging(loggingBuilder =>
        {
            loggingBuilder.AddConsole();
        });

        services.AddCoreMetrics();
        services.AddSingleton<IFunctions, FunctionsRuntime>();

        services = telemetryProvider switch
        {
            // TODO: "ApplicationInsights" => services.AddApplicationInsightsCoreTelemetry(configuration),
            "OpenTelemetry" => services.AddOpenCoreTelemetry(configuration.GetSection("OpenTelemetrySettings").Get<OpenTelemetrySettings>()),
            _ => services.AddSingleton<ICoreTelemetry, NullCoreTelemetry>(),
        };
    })
    .Build()
    .RunAsync();
