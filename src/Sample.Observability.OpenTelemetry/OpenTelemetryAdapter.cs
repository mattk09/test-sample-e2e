﻿using System.Diagnostics;

namespace Sample.Observability
{
    public class OpenTelemetryAdapter : ICoreTelemetry
    {
        private static readonly ActivitySource source = new ActivitySource(nameof(OpenTelemetryAdapter));

        public ICoreTelemetrySpan Start(string name)
        {
            return new Span()
            {
                Activity = source.StartActivity(name),
            };
        }

        internal class Span : ICoreTelemetrySpan
        {
            public Activity Activity { get; init; }

            public void SetTag(string key, object value)
            {
                this.Activity?.SetTag(key, value);
            }

            public void SetBaggage(string key, string value)
            {
                OpenTelemetry.Baggage.SetBaggage(key, value);
            }

            public void Dispose()
            {
                this.Activity?.Dispose();
            }

            public override string ToString()
            {
                return $"{this.Activity?.TraceId.ToString() ?? string.Empty}-{this.Activity?.SpanId.ToString() ?? string.Empty}";
            }
        }
    }
}
