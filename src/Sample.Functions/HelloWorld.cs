using System.Net;
using System.Web;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Sample.Exceptions;
using Sample.Services;

namespace Sample.Functions
{
    public class HelloWorld
    {
        private readonly IFunctions functions;

        public HelloWorld(IFunctions functions)
        {
            this.functions = Guard.ThrowIfNull(functions, nameof(functions));
        }

        [Function("HelloWorld")]
        public async Task<HttpResponseData> RunAsync(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequestData request, FunctionContext context)
        {
            string queryName = HttpUtility.ParseQueryString(request.Url.Query)["name"]?.ToString() ?? "NA";

            var responseMessage = await this.functions.GetAsync(queryName);

            var response = request.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "text/plain; charset=utf-8");
            response.WriteString($"{responseMessage}");

            return response;
        }
    }
}
