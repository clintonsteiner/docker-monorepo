# Build Notes

## Model Baked Into Image

This Docker image includes the Qwen2.5-Coder-32B-Instruct model (~20GB) baked directly into the image layers.

### Build Characteristics

**Build Time:**
- First build: 20-40 minutes (downloads 20GB model)
- Subsequent builds: 1-5 minutes (model layer is cached)

**Image Size:**
- Base Open WebUI: ~2GB
- Qwen2.5-Coder model: ~20GB
- Config and customizations: ~50MB
- **Total**: ~22-25GB

**Build Resources:**
- Disk space required: ~30GB (build cache + final image)
- Network: 20GB download from HuggingFace
- CPU: Minimal (mostly download time)

### Advantages of Baked-In Model

✅ **Instant Deployment**
- No post-deployment model download
- Container is ready to use immediately
- Predictable startup time (~30-60 seconds)

✅ **Offline Capability**
- Model is always available
- No internet required after initial pull
- Reliable in air-gapped environments

✅ **Version Control**
- Model version is locked to image tag
- Reproducible deployments
- Easy rollback to previous model versions

✅ **Simplified Operations**
- One-step deployment (`docker run`)
- No separate model management
- Fewer failure points

### Disadvantages

❌ **Large Image Size**
- 22-25GB vs ~2GB for base image
- Slower docker pull/push operations
- More storage required on registry and host

❌ **Longer Build Times**
- Initial build: 20-40 minutes
- CI/CD builds take longer
- More bandwidth usage

❌ **Model Updates**
- Requires rebuilding entire image for model updates
- Cannot swap models without new build
- Larger deployment artifacts

## Build Process Details

The Dockerfile downloads the model during build:

```dockerfile
RUN ollama serve > /dev/null 2>&1 & \
    OLLAMA_PID=$! && \
    sleep 5 && \
    ollama pull qwen2.5-coder:32b-instruct-q5_K_M && \
    kill $OLLAMA_PID
```

This approach:
1. Starts Ollama service in background
2. Waits for startup (5 seconds)
3. Pulls the model using Ollama's standard mechanism
4. Stops Ollama service
5. Commits model to image layer

The model is stored in `/root/.ollama/models` and is available immediately when the container starts.

## Alternative: External Model

If you prefer to keep the image small and download the model at runtime:

1. Comment out the `RUN ollama pull` section in Dockerfile
2. Rebuild image (will be ~2GB)
3. On first run, manually pull model:
   ```bash
   docker exec coding-agent ollama pull qwen2.5-coder:32b-instruct-q5_K_M
   ```

## GitHub Actions Build

The CI/CD workflow builds multi-architecture images:
- `linux/amd64` - For x86_64 systems (Intel/AMD)
- `linux/arm64` - For ARM systems (Apple Silicon, Raspberry Pi)

Each architecture downloads the model independently, so the total build time is:
- Sequential: 40-80 minutes (one arch at a time)
- Parallel: 20-40 minutes (with sufficient runners)

The workflow uses GitHub Actions cache to speed up subsequent builds.
