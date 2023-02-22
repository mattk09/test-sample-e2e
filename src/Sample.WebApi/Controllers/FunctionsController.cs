using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Sample.Exceptions;
using Sample.Services;

namespace Sample.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class FunctionsController : ControllerBase
    {
        private readonly IFunctions functions;

        public FunctionsController(IFunctions functions)
        {
            this.functions = Guard.ThrowIfNull(functions, nameof(functions));
        }

        [HttpGet]
        public Task<string> GetAsync()
        {
            var name = this.HttpContext.Request.Query["name"];

            return this.functions.GetAsync(string.IsNullOrWhiteSpace(name) ? "NA" : name);
        }

        [HttpGet("secure")]
        public Task<string> GetSecureAsync()
        {
            return this.functions.GetSecureAsync();
        }
    }
}
