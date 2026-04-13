# AgentMLX

A Swift Package that wraps MLX Swift LLM inference, pre-configured to run **Llama-3.2-3B-Instruct-4bit** locally on Apple Silicon via the MLX framework.

---

## Requirements

| Tool | Version |
|------|---------|
| macOS | 14.0+ (Apple Silicon required) |
| Xcode | 15.0+ |
| Python | 3.10+ |
| pip / pipx | latest |

---

## 1. Install Python & MLX tooling

### 1a. Install `huggingface_hub` CLI (for model downloads)

```bash
pip install huggingface_hub[cli]
```

Or with `pipx` (isolated environment, recommended):

```bash
pipx install huggingface_hub[cli]
```

Verify the install:

```bash
hf --version
# or
huggingface-cli --version
```

### 1b. Install the `mlx-lm` Python package (optional — for testing the model from Python first)

```bash
pip install mlx-lm
```

This installs:
- `mlx` — Apple Silicon ML framework (Python bindings)
- `mlx-lm` — LLM generation utilities (generation, tokenizer, chat)
- `transformers` — Hugging Face model utilities
- `huggingface_hub` — model download helpers

---

## 2. Download the model

Use the `huggingface-cli` (alias `hf`) to download the quantised Llama model from the [mlx-community](https://huggingface.co/mlx-community) organisation.

### Recommended folder structure

AgentMLX expects models to live inside a `Models/` folder **at the root of your project** so that relative paths work out of the box both in Swift and in the generation script:

```
AgentMLX/
├── Package.swift
├── README.md
├── Models/                                     ← put all models here
│   └── Llama-3.2-3B-Instruct-4bit/            ← one folder per model
│       ├── config.json
│       ├── tokenizer.json
│       ├── tokenizer_config.json
│       └── model.safetensors (or *.safetensors shards)
└── Sources/
    └── AgentMLX/
```

### Download commands

```bash
# 1. Create the Models directory inside your project (run once)
mkdir -p ./Models

# 2. Download directly into the correct folder
hf download mlx-community/Llama-3.2-3B-Instruct-4bit \
    --local-dir ./Models/Llama-3.2-3B-Instruct-4bit

# Alternative: use huggingface-cli if `hf` alias is not available
huggingface-cli download mlx-community/Llama-3.2-3B-Instruct-4bit \
    --local-dir ./Models/Llama-3.2-3B-Instruct-4bit
```

> **Note:** The 4-bit quantised model is ~2 GB. Make sure you have enough free disk space.

### Verify the download

After downloading, confirm all required files are present:

```bash
ls ./Models/Llama-3.2-3B-Instruct-4bit
# Expected output includes:
# config.json  tokenizer.json  tokenizer_config.json  *.safetensors
```

### Other useful MLX-community models you can swap in

```bash
hf download mlx-community/Llama-3.2-1B-Instruct-4bit \
    --local-dir ./Models/Llama-3.2-1B-Instruct-4bit        # smaller / faster

hf download mlx-community/Llama-3.1-8B-Instruct-4bit \
    --local-dir ./Models/Llama-3.1-8B-Instruct-4bit        # larger / more capable

hf download mlx-community/Mistral-7B-Instruct-v0.3-4bit \
    --local-dir ./Models/Mistral-7B-Instruct-v0.3-4bit     # Mistral alternative
```

---

## 3. Verify the model (Python — optional)

After downloading, you can test generation from Python before integrating with Swift:

```python
from mlx_lm import load, generate

model, tokenizer = load("mlx-community/Llama-3.2-3B-Instruct-4bit")

response = generate(
    model,
    tokenizer,
    prompt="Tell me a fun fact about Apple Silicon.",
    max_tokens=200,
    verbose=True
)
print(response)
```

Or use the built-in CLI:

```bash
python -m mlx_lm.generate \
    --model mlx-community/Llama-3.2-3B-Instruct-4bit \
    --prompt "Tell me a fun fact about Apple Silicon." \
    --max-tokens 200
```


---

## 4. Swift Package setup

### Add AgentMLX as a dependency

In your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/AgentMLX", from: "1.0.0"),
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "AgentMLX", package: "AgentMLX"),
        ]
    ),
]
```

### Resolve packages in Xcode

```bash
swift package resolve
swift build
```

---

## 5. Usage in Swift

```swift
import AgentMLX

// Create agent — downloads / loads the model automatically
let agent = try await AgentMLX.create()

// Generate a response
let reply = try await agent.generate(with: "Explain Swift concurrency in simple terms.")
print(reply)
```

---

## 6. Project structure

```
AgentMLX/
├── Package.swift               # SPM manifest (mlx-swift-lm + tokenizers)
├── Package.resolved            # Locked dependency versions
├── README.md                   # This file
├── Models/                     # Downloaded model weights (gitignored)
│   └── Llama-3.2-3B-Instruct-4bit/
├── scripts/                    # Python helper scripts
│   └── generate.py             # Quick CLI generation tester
└── Sources/
    └── AgentMLX/
        ├── Agentable.swift     # Protocol definition
        └── AgentMLX.swift      # MLX LLM implementation
```

---

## 7. Troubleshooting

| Problem | Fix |
|---------|-----|
| `hf: command not found` | Run `pip install huggingface_hub[cli]` or add pip bin to `$PATH` |
| Model download fails (auth) | Run `huggingface-cli login` and enter your HF token |
| `swift package resolve` fails | Check Xcode version ≥ 15 and macOS ≥ 14 |
| Out of memory during inference | Use a smaller model (1B/3B) or close other apps |
| `No such module 'MLXLLM'` | Run `swift package resolve` then clean build folder in Xcode |

---

## 8. Useful links

- [MLX Swift GitHub](https://github.com/ml-explore/mlx-swift)
- [mlx-swift-lm GitHub](https://github.com/ml-explore/mlx-swift-lm)
- [mlx-lm Python package](https://github.com/ml-explore/mlx-lm)
- [mlx-community on Hugging Face](https://huggingface.co/mlx-community)
- [Hugging Face CLI docs](https://huggingface.co/docs/huggingface_hub/guides/cli)
