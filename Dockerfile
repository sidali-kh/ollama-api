
# Stage 1: Download and prepare the model
FROM ollama/ollama:latest AS model-builder

# Set model storage directory
ENV OLLAMA_MODELS=/root/.ollama/models

# Download Llama 3.2 3B
RUN ollama serve & \
    pid=$!; \
    for i in $(seq 1 60); do \
      if ollama list >/dev/null 2>&1; then break; fi; \
      sleep 2; \
    done; \
    ollama pull llama3.2:3b; \
    kill $pid; \
    wait $pid || true

# Stage 2: Final production image
FROM ollama/ollama:latest

# Include the downloaded model
COPY --from=model-builder /root/.ollama /root/.ollama

# Listen on all container interfaces
ENV OLLAMA_HOST=0.0.0.0:11434

# Expose Ollama API
EXPOSE 11434

# Start Ollama directly
ENTRYPOINT ["ollama"]
CMD ["serve"]
