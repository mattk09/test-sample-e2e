using System;
using System.Threading.Tasks;

namespace Sample.Services.Functions
{
    public class FunctionsSimulator : IFunctions
    {
        public async Task<string> GetAsync(string name)
        {
            await Task.Delay(TimeSpan.FromSeconds(1));

            return $"simulated: {name}";
        }

        public async Task<string> GetSecureAsync()
        {
            await Task.Delay(TimeSpan.FromSeconds(1));

            return "simulated secure";
        }
    }
}
