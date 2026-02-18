#!/bin/bash
# Ollama startup script
# Model pulling happens automatically via docker environment or manual init

exec ollama serve
