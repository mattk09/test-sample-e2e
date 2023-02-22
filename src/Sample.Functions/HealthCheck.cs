using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;

namespace Sample.Functions
{
    public class HealthCheck
    {
        [Function("healthcheck")]
        public Task<HttpResponseData> HealthCheckAsync([HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData request)
        {
            var response = request.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "text/plain; charset=utf-8");
            response.WriteString("Healthy");

            return Task.FromResult<HttpResponseData>(response);
        }
    }
}
