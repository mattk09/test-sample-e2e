using System.Diagnostics;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Middleware;

internal sealed class FunctionActivityRootMiddleware : IFunctionsWorkerMiddleware
{
    public async Task Invoke(FunctionContext context, FunctionExecutionDelegate next)
    {
        var requestData = await context.GetHttpRequestDataAsync();

        var traceParent = string.Empty;
        foreach (var item in requestData.Headers)
        {
            if (item.Key == "traceparent")
            {
                traceParent = item.Value.FirstOrDefault(string.Empty);
            }
        }

        ActivityContext activityContext;
        ActivitySource source = null;

        if (ActivityContext.TryParse(traceParent, null, out activityContext))
        {
            Console.WriteLine($"{activityContext.TraceId}-{activityContext.SpanId}");

            source = new ("Sample.Functions");
        }

        using var disposable = source;
        using Activity activity = source?.StartActivity(nameof(FunctionActivityRootMiddleware), ActivityKind.Server, activityContext);

        await next(context);
    }
}
