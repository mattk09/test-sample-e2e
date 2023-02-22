using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Sample.Exceptions;
using Sample.Services;

namespace Sample.Functions
{
    public class HelloWorldSecure
    {
        private readonly IFunctions functions;

        public HelloWorldSecure(IFunctions functions)
        {
            this.functions = Guard.ThrowIfNull(functions, nameof(functions));
        }

        [Function("HelloWorldSecure")]
        public async Task<HttpResponseData> RunSecureAsync(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequestData request)
        {
            var response = request.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "text/plain; charset=utf-8");
            response.WriteString(await this.functions.GetSecureAsync());

            return response;
        }
    }
}
