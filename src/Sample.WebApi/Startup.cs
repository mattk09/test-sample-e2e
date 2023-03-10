using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Sample.Extensions;
using Sample.Observability;
using Sample.Services;
using Sample.Services.Weather;
using Sample.Settings;

namespace Sample
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            // Read 'SampleSettings'
            var settings = new SampleSettings();
            this.Configuration.Bind(settings);

            services.AddCoreMetrics(services.AddHealthChecks());

            services.AddSingleton<IWeatherForecaster, WeatherForecaster>();

            // Add the the proper ISampleStorage and related services based on configuration
            services.AddSampleStorage(settings);

            services.AddSampleFunctions(settings);

            services = settings.TelemetryProvider switch
            {
                TelemetryProvider.ApplicationInsights => services.AddApplicationInsightsCoreTelemetry(this.Configuration),
                TelemetryProvider.OpenTelemetry => services.AddOpenCoreTelemetry(settings.OpenTelemetrySettings),
                _ => services.AddSingleton<ICoreTelemetry, NullCoreTelemetry>(),
            };

            services.AddControllers();

            // Register the Swagger services
            services.AddOpenApiDocument();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public static void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseHttpsRedirection();
            }

            var coreMetrics = app.ApplicationServices.GetRequiredService<ICoreMetrics>();
            coreMetrics.ApplicationInfo();

            // Use middleware to route '/' to swagger
            app.Use(async (context, nextAsync) =>
            {
                coreMetrics.OnHit(context.Request.Path.Value);

                if (context.Request.Path.Value == "/")
                {
                    // Rewrite and continue processing
                    context.Request.Path = "/swagger";
                }

                await nextAsync();
            });

            app.UseRouting();
            app.UseAuthentication();
            app.UseAuthorization();

            app.UseCoreMetricsMiddleware();

            // Register the Swagger generator and the Swagger UI middlewares
            app.UseOpenApi();
            app.UseSwaggerUi3();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
                endpoints.MapHealthChecks("healthcheck");
                endpoints.MapCoreMetrics();
            });

            // Exception simulator
            app.Use(async (context, nextAsync) =>
            {
                if (context.Request.Path.Value.Contains("exception", StringComparison.OrdinalIgnoreCase))
                {
                    throw new InvalidOperationException($"Throw with request {context.Request.Path.Value}");
                }

                await nextAsync();
            });
        }
    }
}
