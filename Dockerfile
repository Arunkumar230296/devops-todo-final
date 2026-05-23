# Stage 1 - Build
FROM python:3.12-slim AS builder

WORKDIR /app

COPY app/requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2 - Runtime
FROM python:3.12-slim

WORKDIR /app

RUN groupadd -r appgroup && useradd -r -g appgroup appuser

COPY --from=builder /install /usr/local
COPY app/ .

ENV PYTHONUNBUFFERED=1

EXPOSE 8080

USER appuser

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "main:app"]s