# A local learning image. For production, pin the base image by digest and use a production web server.
FROM python:3.13-alpine
WORKDIR /app
COPY --chown=10001:10001 site/ /app/
USER 10001:10001
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/', timeout=2)" || exit 1
CMD ["python", "-m", "http.server", "8000", "--bind", "0.0.0.0"]
