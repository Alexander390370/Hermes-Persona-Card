# 模型与 Provider 配置

> 全部内容摘自本机 `config.yaml` 的实际注释与配置，非二手转述。

## 配置位置

```
%LOCALAPPDATA%\hermes\config.yaml
```

## 最小配置

```yaml
model:
  default: "deepseek-flash"
  provider: "deepseek"
  base_url: "https://api.deepseek.com/v1"
```

三个键：

| 键 | 作用 |
|---|---|
| `default` | 默认模型名（可用 `--model` 覆盖） |
| `provider` | 走哪个 provider |
| `base_url` | 该 provider 的端点 |

## Provider 完整列表

| provider | 需要的凭据 | 说明 |
|---|---|---|
| `auto` | — | 从已有凭据自动检测（默认） |
| `openrouter` | `OPENROUTER_API_KEY` 或 `OPENAI_API_KEY` | OpenRouter 聚合 |
| `nous` | `hermes auth add nous`（OAuth） | Nous Portal OAuth |
| `nous-api` | `NOUS_API_KEY` | Nous Portal API key |
| `anthropic` | `ANTHROPIC_API_KEY` | Anthropic 直连 |
| `openai-codex` | `hermes auth` | OpenAI Codex |
| `copilot` | `GITHUB_TOKEN` | GitHub Copilot / Models |
| `gemini` | `GOOGLE_API_KEY` 或 `GEMINI_API_KEY` | Google AI Studio |
| `zai` | `GLM_API_KEY` | z.ai / 智谱 GLM |
| `kimi-coding` | `KIMI_API_KEY` | Kimi / Moonshot |
| `minimax` | `MINIMAX_API_KEY` | MiniMax 国际 |
| `minimax-cn` | `MINIMAX_CN_API_KEY` | MiniMax 中国 |
| `huggingface` | `HF_TOKEN` | HF Inference |
| `nvidia` | `NVIDIA_API_KEY` | NVIDIA NIM / build.nvidia.com |
| `xiaomi` | `XIAOMI_API_KEY` | 小米 MiMo |
| `arcee` | `ARCEEAI_API_KEY` | Arcee AI Trinity |
| `ollama-cloud` | `OLLAMA_API_KEY` | Ollama Cloud |
| `deepinfra` | `DEEPINFRA_API_KEY` | DeepInfra |
| `kilocode` | `KILOCODE_API_KEY` | KiloCode gateway |
| `ai-gateway` | `AI_GATEWAY_API_KEY` | Vercel AI Gateway |
| `azure-foundry` | API key 或 Entra ID | Microsoft Foundry / Azure OpenAI |
| `lmstudio` | 可选 `LM_API_KEY` | 默认 `http://127.0.0.1:1234/v1` |
| **`custom`** | `base_url` | **任意 OpenAI 兼容端点** |

## 凭据放哪

```
%LOCALAPPDATA%\hermes\.env
```

实测键名：

```ini
DEEPSEEK_API_KEY=sk-...
DEEPSEEK_BASE_URL=https://api.deepseek.com/v1
KIMI_CN_API_KEY=sk-...
DASHSCOPE_API_KEY=sk-...
DASHSCOPE_BASE_URL=...
HERMES_CUSTOM_DEEPSEEK_API_KEY=sk-...
```

> `HERMES_CUSTOM_*` 是自定义端点的密钥前缀：如果 provider 设成 `custom` 且用私有网关，
> 用这个前缀避免和官方 key 冲突。

## 接本地模型

`config.yaml` 注释原文把本地服务归到 `custom`：

> Local servers (LM Studio, Ollama, vLLM, llama.cpp):
> `"custom"` - Any other OpenAI-compatible endpoint. Set base_url below.

### 配置

```yaml
model:
  default: "deepseek9b"
  provider: "custom"
  base_url: "http://127.0.0.1:8440/v1"
```

### 三个必须对齐的参数

**1. 别名一致**

llama-server 启动时 `--alias deepseek9b`，`default` 就得是 `deepseek9b`。
别名不对会报「模型不存在」。

**2. 上下文够用且不被切分**

`--parallel N` 会把 `-c` 切分：

```
--parallel 2 + -c 32768  →  每槽 16384
```

Hermes 请求的上下文可能超过单槽，就会超限。**本地模型建议 `--parallel 1`**。

**3. 端口对上**

`base_url` 的端口要和 `--port` 一致。

### 完整启动示例

```bash
llama-server \
  -m model-Q4_K_M.gguf \
  --host 0.0.0.0 --port 8440 \
  -ngl 99 -fa on \
  -c 32768 \
  --parallel 1 \
  --alias deepseek9b \
  --jinja
```

## 验证配置是否生效

```bash
# 看 provider 列表
hermes providers

# 或直接问一句
hermes "用一句话介绍你自己"
```

## 已知坑

### `--parallel` 切分上下文

见上，实测踩过。DSH 默认 `maxTokens = 32768`，槽位一小就判定超限。

### 进程被 WSL 回收

`wsl.exe -e bash -c "..."` 命令返回后，WSL 会回收整个会话树。
服务看着起来了，命令一结束就没了。

必须三重脱离：

```bash
setsid nohup bash -c "exec llama-server ..." &
disown
```

### `max_tokens` 别设太大

模型 `contextWindow = 32768` 时，`max_tokens` 也设 32768 会让输入+输出必然超限。
建议 4096，给输入留空间。

### 思考链吃 token

推理模型在小 `max_tokens`（比如 40）下会出现 `content` 为空、
`reasoning_content` 塞满的情况。这是模型行为，不是配置错误。

## 姊妹项目

本地模型的显存实测、上下文取舍、进程脱离等细节：

[DeepSeek9B-8GB-VRAM-Setup](https://github.com/Alexander390370/DeepSeek9B-8GB-VRAM-Setup)
