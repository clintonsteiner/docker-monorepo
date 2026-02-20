# Coding Agent - Self-Hosted Claude Code Alternative

A locally hosted coding agent powered by **Qwen2.5-Coder-32B** running on **Open WebUI**.

## Features

- 🌐 **Web Interface** - Access from any device on your network
- 🤖 **Qwen2.5-Coder-32B** - Best open-source coding model (2026)
- 💻 **Code Execution** - Built-in Python sandbox for running code
- 📝 **File Operations** - Upload/download files, read and modify code
- 🔍 **Code Understanding** - 128K context window (entire codebases)
- 💬 **ChatGPT-like Interface** - Familiar, easy to use
- 🔌 **Claude Code Compatible** - Use with actual Claude CLI
- 🔒 **Fully Self-Hosted** - No external API calls, all local

## Hardware Requirements

**Minimum**:
- CPU: 8 cores
- RAM: 40GB
- Disk: 30GB

**Recommended** (tested on):
- CPU: i9-12900k (16 cores)
- RAM: 96GB DDR5
- Disk: 50GB SSD

## Quick Start

1. **Start the service**:
   ```bash
   cd coding-agent
   make start
   ```

2. **Open your browser**:
   - Go to: http://unraid.clintonsteiner.com:3000
   - (or http://192.168.1.50:3000)

3. **Download the model** (first time only):
   - In the Web UI, go to **Settings → Models**
   - Click "Pull a model from Ollama.com"
   - Enter: `qwen2.5-coder:32b-instruct-q5_K_M`
   - Wait for download (~20GB, may take 10-20 minutes)

4. **Start coding**:
   - Select the model from the dropdown
   - Start chatting with your AI coding assistant!

## Network Access

**Internal Network** (recommended):
- http://unraid.clintonsteiner.com:3000
- http://192.168.1.50:3000 (replace with your Unraid IP)

**External Access** (optional, via Caddy):
- https://code.clintonsteiner.com
- Add authentication for security

## Using with Claude Code CLI

You can use the actual Claude Code CLI with your self-hosted model!

1. **Configure Claude Code**:
   ```bash
   # Edit ~/.claude/config.json
   {
     "apiKey": "sk-local",
     "baseURL": "http://unraid.clintonsteiner.com:3000/v1",
     "model": "qwen2.5-coder:32b-instruct-q5_K_M",
     "modelFamily": "openai-compatible"
   }
   ```

2. **Run Claude Code normally**:
   ```bash
   claude
   ```

Now Claude Code will use your local model instead of Anthropic's API!

**Switch between local and Anthropic**:
```bash
# Use local model
export ANTHROPIC_BASE_URL="http://unraid.clintonsteiner.com:3000/v1"

# Use Anthropic API
unset ANTHROPIC_BASE_URL
```

## Performance

**On i9-12900k with 96GB RAM**:
- **Inference Speed**: 5-8 tokens/second
- **First Load**: ~30-60 seconds
- **Context Window**: 32K tokens (configurable up to 128K)
- **Memory Usage**: ~35-40GB
- **Response Quality**: Competitive with GPT-4 on code tasks

## Architecture

```
Browser → Open WebUI (Web Interface + Ollama Backend)
   ↓
Qwen2.5-Coder-32B (Q5_K_M quantization, 20GB)
```

**Single container** - No complex setup!

## Configuration

Edit `docker-compose.yml` to customize:
- CPU/memory limits
- Context window size (OLLAMA_NUM_CTX)
- Number of threads (OLLAMA_NUM_THREADS)
- Model keep-alive time

## Usage Examples

**Web UI**:
1. Open http://unraid.clintonsteiner.com:3000
2. Type your request:
   - "Read the README.md file and summarize it"
   - "Create a Python script to parse CSV files"
   - "Find the bug in app.py causing the login error"
   - "Refactor this code to use async/await"

**Claude Code CLI**:
```bash
# Point to local model
claude --model qwen2.5-coder:32b-instruct-q5_K_M

# Use exactly like normal Claude Code
> Read the codebase and explain what it does
> Add a new REST API endpoint for user auth
> Fix the bug in the payment processing
```

## Maintenance

**View logs**:
```bash
make logs
```

**Restart service**:
```bash
make restart
```

**Check status**:
```bash
make status
```

**Update**:
```bash
git pull
make restart
```

## Troubleshooting

**Model not loading**:
- Check memory usage: `docker stats`
- Reduce context window in docker-compose.yml
- Try smaller model: `qwen2.5-coder:14b-instruct-q5_K_M`

**Slow responses**:
- Normal for CPU inference (5-8 tokens/sec is expected)
- Increase OLLAMA_NUM_THREADS for more CPU cores
- Try lower quantization (Q4_K_M) for speed

**Can't access from network**:
- Check firewall on Unraid
- Verify port 3000 is open
- Use IP address instead of hostname

## Support

- Model: [Qwen2.5-Coder on HuggingFace](https://huggingface.co/Qwen/Qwen2.5-Coder-32B-Instruct)
- Open WebUI: [Documentation](https://docs.openwebui.com/)
- Issues: [GitHub Issues](https://github.com/clintonsteiner/docker-monorepo/issues)
