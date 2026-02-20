# Configuration Files

This directory contains custom configuration files for the Coding Agent.

## Files

### custom-settings.json

Default settings for the coding agent including:
- Model parameters (temperature, top_p, max_tokens)
- Code execution settings
- System prompts optimized for coding tasks
- UI preferences

### modelfiles/qwen-coder.modelfile

Ollama Modelfile for Qwen2.5-Coder-32B with:
- Optimized system prompt for coding assistance
- Tuned parameters for code generation
- Context window configuration
- Stop sequences

## Customization

To customize the configuration:

1. **Edit settings**: Modify `custom-settings.json`
2. **Edit model prompt**: Modify `modelfiles/qwen-coder.modelfile`
3. **Rebuild image**: Run `make build` from the coding-agent directory
4. **Restart service**: Run `make restart`

## System Prompt

The default system prompt is optimized for:
- Clean, efficient code generation
- Debugging and troubleshooting
- Explaining complex concepts
- Following best practices
- Production-ready code with error handling

Feel free to adjust the prompt to match your coding style and preferences!
