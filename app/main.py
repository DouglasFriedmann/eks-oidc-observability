from fastapi import FastAPI
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from starlette.responses import Response
import time
import random

app = FastAPI(title="EKS Observability Lab")

REQ_COUNT = Counter("http_requests_total", "Total HTTP requests", ["path"])
REQ_LATENCY = Histogram("http_request_latency_seconds", "Request latency", ["path"])

@app.get("/")
def root():
    REQ_COUNT.labels(path="/").inc()
    return {"ok": True, "service": "eks-observability-lab"}

@app.get("/healthz")
def healthz():
    REQ_COUNT.labels(path="/healthz").inc()
    return {"status": "healthy"}

@app.get("/work")
def work():
    path = "/work"
    REQ_COUNT.labels(path=path).inc()
    start = time.time()
    # Simulate variable work
    time.sleep(random.uniform(0.05, 0.35))
    REQ_LATENCY.labels(path=path).observe(time.time() - start)
    return {"status": "done"}

@app.get("/metrics")
def metrics():
    data = generate_latest()
    return Response(content=data, media_type=CONTENT_TYPE_LATEST)

