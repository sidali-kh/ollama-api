
# Stage 1: Download the lightweight model
FROM ollama/ollama:latest AS model-builder

ENV OLLAMA_MODELS=/root/.ollama/models

RUN ollama serve & \
    pid=$!; \
    for i in $(seq 1 60); do \
      if ollama list >/dev/null 2>&1; then break; fi; \
      sleep 2; \
    done; \
    ollama pull smollm2:360m-instruct-q2_K; \
    kill $pid; \
    wait $pid || true

# Stage 2: Production
FROM ollama/ollama:latest

COPY --from=model-builder /root/.ollama /root/.ollama

ENV OLLAMA_HOST=0.0.0.0:11434
ENV OLLAMA_MODELS=/root/.ollama/models

# Limit memory usage
ENV OLLAMA_CONTEXT_LENGTH=512
ENV OLLAMA_NUM_PARALLEL=1
ENV OLLAMA_MAX_LOADED_MODELS=1
ENV OLLAMA_KEEP_ALIVE=0

EXPOSE 11434

ENTRYPOINT ["ollama"]
CMD ["serve"]
