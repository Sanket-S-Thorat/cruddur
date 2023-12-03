# Week 2 — Distributed Tracing

- Open-Telemetry:https://opentelemetry.io/
CNCF Basis on which observability tools work

- Importing Honeycomb API key
```
export HONEYCOMB_API_KEY="qQo5nuOQ7BGVEc1vz6wiJD"
gp env HONEYCOMB_API_KEY="qQo5nuOQ7BGVEc1vz6wiJD"
```

- # HONEYCOMB INSTRUMENTATION
- Honeycomb docs: docs.honeycomb.io

- Import the Env vars for Honeycomb service and Open Telemetry

So add the envars under Docker compose.
```
# Env Vars for Honeycomb.io
OTEL_SERVICE_NAME: "backend-flask"
OTEL_EXPORTER_OTLP_ENDPOINT: "https://api.honeycomb.io"
OTEL_EXPORTER_OTLP_HEADERS: "x-honeycomb-team=${HONEYCOMB_API_KEY}"
```

- Now lets add dependency to use telemetry
```
opentelemetry-api 
opentelemetry-sdk 
opentelemetry-exporter-otlp-proto-http 
opentelemetry-instrumentation-flask 
opentelemetry-instrumentation-requests
```

- Let modify our backend-app to use the opentelemtry- Honeycomb.io
```
## Telemtry modules for Honeycomb
from opentelemetry import trace
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
```

```
# Initialize tracing and an exporter that can send data to Honeycomb
provider = TracerProvider()
processor = BatchSpanProcessor(OTLPSpanExporter())
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)
tracer = trace.get_tracer(__name__)
```

