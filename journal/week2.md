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

- Add tracers wherever you want
```
from opentelemetry import trace

with tracer.start_as_current_span("mock-home-data"):
    <your code>
    # Honeycomb: Creating Span manually
      span = trace.get_current_span()
      span.set_attribute("app.run.time", some_relevant_value)
    # Using the span object above you can create multiple spans
    # Reason to do this: replace the loggers with Span and instead of reading logs observe them. That's Observability.
```

- ## Setting up Rollbar

- Add dependency to backend 
```
blinker
rollbar
```

- Add Rollbar Access token Env Vars
```
export ROLLBAR_ACCESS_TOKEN=""
gp env ROLLBAR_ACCESS_TOKEN=""
```

- In app.py backend

```
#Import modules
import os
import rollbar
import rollbar.contrib.flask
from flask import got_request_exception

#Initialize the Rollbar object
rollbar_access_token = os.getenv('ROLLBAR_ACCESS_TOKEN')

with app.app_context():
    """init rollbar module"""
    rollbar.init(
        # access token
        rollbar_access_token,
        # environment name
        'production',
        # server root directory, makes tracebacks prettier
        root=os.path.dirname(os.path.realpath(__file__)),
        # flask already sets up logging
        allow_logging_basic_config=False)

    # send exceptions from `app` to rollbar, using flask's signal system.
    got_request_exception.connect(rollbar.contrib.flask.report_exception, app)

#Test if it is working
@app.route('/rollbar/test')
def rollbar_test():
    rollbar.report_message('Hello World!', 'warning')
    return "Hello World!"
```

- # Setting up AWS X-Ray
```
export AWS_DEFAULT_REGION="ap-south-1"
```

- Deps
```
aws-xray-sdk
```

- Modification to app.py
```
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.ext.flask.middleware import XRayMiddleware

xray_url = os.getenv("AWS_XRAY_URL")
xray_recorder.configure(service='Cruddur', dynamic_naming=xray_url)
XRayMiddleware(app, xray_recorder)
```

- Create an X-Ray group
```
FLASK_ADDRESS="https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}"
aws xray create-group \
   --group-name "Cruddur" \
   --filter-expression "service(\"$FLASK_ADDRESS\") {fault OR error}"
```

- Create a Sampling rule:
```
#xray.json
{
  "SamplingRule": {
      "RuleName": "Cruddur",
      "ResourceARN": "*",
      "Priority": 9000,
      "FixedRate": 0.1,
      "ReservoirSize": 5,
      "ServiceName": "Cruddur",
      "ServiceType": "*",
      "Host": "*",
      "HTTPMethod": "*",
      "URLPath": "*",
      "Version": 1
  }
}
```





### Homework
1. Instrument the honeycomb for frontend to observe network latency between frontend and backend latency.
2. Add custom instrumentation to Honeycomb to add more attributes eg. UserId, Add a custom span.
3. Run custom queries in Honeycob and save them later. eg. Latency by userId, recent traces.