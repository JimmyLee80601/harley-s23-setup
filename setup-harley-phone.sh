#!/data/data/com.termux/files/usr/bin/bash
# Harley Vision 3B Setup — Termux llama.cpp server
# Run this in Termux after installing packages

echo "=== Installing dependencies ==="
pkg update -y
pkg install -y clang cmake git binutils

echo "=== Installing llama.cpp from pip ==="
pip install llama-cpp-python

echo "=== Or build from source for NEON acceleration ==="
cd ~
if [ ! -d "llama.cpp" ]; then
    git clone https://github.com/ggml-org/llama.cpp.git
fi
cd llama.cpp
cmake -B build -DGGML_NATIVE=ON
cmake --build build --config Release -j4

echo "=== Downloading model from HuggingFace ==="
MODEL_DIR="$HOME/models"
mkdir -p "$MODEL_DIR"
MODEL_FILE="$MODEL_DIR/Qwen2.5-VL-3B-Q4_K_M.gguf"

if [ ! -f "$MODEL_FILE" ]; then
    echo "Downloading Qwen2.5-VL-3B-Instruct Q4_K_M (1.84GB)..."
    curl -L -o "$MODEL_FILE" \
        "https://huggingface.co/lmstudio-community/Qwen2.5-VL-3B-Instruct-GGUF/resolve/main/Qwen2.5-VL-3B-Instruct-Q4_K_M.gguf" \
        --progress-bar
fi

echo "=== Starting llama-server on port 8080 ==="
echo "Model: $MODEL_FILE"
echo "Server: http://127.0.0.1:8080/v1"
echo "Vision: ENABLED (mmproj will be auto-detected)"
echo ""
echo "Open another Termux session to run opencode, or use:"
echo "  cd ~/llama.cpp && ./build/bin/llama-server -m $MODEL_FILE --host 0.0.0.0 --port 8080 -c 4096 -ngl 99"

./build/bin/llama-server \
    -m "$MODEL_FILE" \
    --host 0.0.0.0 \
    --port 8080 \
    -c 4096 \
    -ngl 99
