FROM python:3.12-slim AS builder

WORKDIR /app

COPY app/requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


FROM python:3.12-slim

WORKDIR /app

RUN groupadd -r appgroup && useradd -r -g appgroup appuser

COPY --from=builder /install /usr/local
COPY app/ .

ENV PYTHONUNBUFFERED=1
ENV PORT=8080

EXPOSE 8080

USER appuser

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "main:app"]