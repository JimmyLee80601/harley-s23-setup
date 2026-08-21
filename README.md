# Harley S23 Phone Setup

## Files
- **opencode.json** - Replace phone's config (points at local Termux llama.cpp, Dell fallback)
- **setup-harley-phone.sh** - Run in Termux to install llama.cpp + download model

## Quick Start
1. Copy opencode.json to phone: /sdcard/Documents/opencode.json
2. Open Termux, run: bash setup-harley-phone.sh
3. In new Termux session: cd ~/llama.cpp && ./build/bin/llama-server -m ~/models/Qwen2.5-VL-3B-Q4_K_M.gguf --host 0.0.0.0 --port 8080 -c 4096 -ngl 99
4. Open opencode - connects to local model
