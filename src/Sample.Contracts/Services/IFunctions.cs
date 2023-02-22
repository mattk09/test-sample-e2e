using System.Threading.Tasks;

namespace Sample.Services
{
    public interface IFunctions
    {
        Task<string> GetAsync(string name);

        Task<string> GetSecureAsync();
    }
}
