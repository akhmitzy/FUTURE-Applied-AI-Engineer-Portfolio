# --- build stage: install deps into an isolated prefix
FROM python:3.12-slim AS build
WORKDIR /src
COPY pyproject.toml ./
COPY app ./app
COPY data ./data
RUN pip install --no-cache-dir --prefix=/install .

# --- runtime stage: small, non-root
FROM python:3.12-slim
ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 PORT=8080
RUN useradd --create-home --uid 10001 app
WORKDIR /srv
COPY --from=build /install /usr/local
COPY app ./app
COPY data ./data
USER app
EXPOSE 8080
CMD ["uvicorn", "app.server:app", "--host", "0.0.0.0", "--port", "8080", "--timeout-keep-alive", "75", "--proxy-headers"]
