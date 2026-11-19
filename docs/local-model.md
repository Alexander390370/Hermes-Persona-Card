# 本地模型部署

> 在 8GB 笔记本显卡上跑 Qwen3.5-4B 无审查模型，接进 Hermes。
> 全部参数在 RTX 4060 Laptop（8188 MiB）+ WSL2 Ubuntu 上实测。

---

## 为什么推荐这个模型

| 能力 | 数值 |
|---|---|
| 底座 | Qwen3.5-4B |
| 量化 | Q4_K_M，**2.52 GB** |
| 上下文 | **96K**（98304） |
| 视觉 | ✅ 支持（mmproj） |
| 审查 | **无审查**（Heretic 消融） |
| 生成速度 | **55~68 tok/s** |
| 显存占用 | 约 6.6 GB |

**4B 的好处是「够用且省」。** 在 8GB 卡上能开到 96K 上下文还留 1.3GB 余量，
同时跑得比 9B 快一倍。

---

## 两个模型，按需选

脚本里配了两个，**8GB 卡同时只能跑一个**。

| 模型 | 别名 | 端口 | 特点 | 用途 |
|---|---|---:|---|---|
| Qwopus3.5-4B-Coder-MTP | `qwopus4b` | **8400** | 有审查，**支持工具调用** | 写代码、日常对话 |
| Qwen3.5-4B-Heretic | `heretic4b` | **8420** | **无审查**，有视觉 | 不受限的对话/角色扮演 |

**选型建议：**

- 要**工具调用**（读文件、跑命令）→ `qwopus`
- 要**无审查** + 图像理解 → `heretic`
- 两个都要 → 只能分开跑，切换时重启

---

## 文件清单

实测大小（字节数照抄）：

| 文件 | 大小 |
|---|---:|
| `Qwen35-4B-Heretic-Q4_K_M.gguf` | 2,707,514,720（2.52 GB） |
| `Qwen3.5-4B-heretic.mmproj-Q8_0.gguf` | 366,894,720（0.34 GB） |
| `Qwopus3.5-4B-Coder-MTP-Q4_K_M.gguf` | 2,783,446,560（2.59 GB） |
| `Qwopus3.5-4B-Coder-MTP.mmproj-F32.gguf` | 675,568,704（0.63 GB） |

**mmproj 是视觉投影。没有它模型只能读文本。**

---

## 启动脚本

### 结构

```bash
#!/bin/bash
# start-local-model.sh - launch local models on 8GB VRAM

MODELS=/mnt/c/Users/<你>/Documents/deepseek-harness/default-workspace/models
LLAMA_DIR=/home/<你>/bonsai/llama-prism-b10743-adfffbe
NV=/home/<你>/miniconda3/envs/dsh-bonsai/lib/python3.11/site-packages/nvidia

export LD_LIBRARY_PATH="$NV/cublas/lib:$NV/cuda_runtime/lib:$NV/cuda_nvrtc/lib:/usr/lib/wsl/lib:$LLAMA_DIR"

CTX=98304           # 96K
BUDGET_MSG="Stop thinking and give the final answer now."
```

### 核心启动参数

```bash
setsid nohup ./llama-server \
    -m "$model" \
    -mm "$mmproj" \
    --host 0.0.0.0 --port "$port" \
    -ngl 99 -fa on -c 98304 \
    --cache-type-k q4_0 --cache-type-v q4_0 \
    --parallel 1 --fit off --jinja --no-warmup \
    --reasoning-budget 400 \
    --reasoning-budget-message "Stop thinking and give the final answer now." \
    --alias "$name" \
    > "/home/<你>/bonsai/${name}.log" 2>&1 < /dev/null &
disown
```

### 用法

```bash
./start-local-model.sh qwopus    # 端口 8400，工具调用
./start-local-model.sh heretic   # 端口 8420，无审查 + 视觉
./start-local-model.sh stop      # 停止全部
./start-local-model.sh status    # 查看状态
```

### 就绪检测

脚本内置 120 秒轮询（40 次 × 3 秒）：

```bash
for i in $(seq 1 40); do
    sleep 3
    if curl -sf -m 2 "http://127.0.0.1:${port}/v1/models" >/dev/null 2>&1; then
        echo "  ready on :$port"
        return 0
    fi
done
echo "  ERROR: did not become ready in 120s"
tail -5 "/home/<你>/bonsai/${name}.log"
```

**不是「启动命令返回就绪」，而是真的能查 `/v1/models`。** 这点很重要。

---

## 关键参数解释

### `-c 98304` —— 96K 是这张卡的上限

脚本注释原文：

> Config: 96K context + q4_0 KV cache + mmproj → ~6.6GB VRAM, ~1.3GB headroom.
> Measured: 128K hits 7.3GB/8GB and OOMs when the desktop is busy.
> **96K is the safe ceiling for this 8GB card.**

**128K 会 OOM**，特别是桌面还在跑别的程序时。96K 是实测的安全线。

### `--cache-type-k q4_0 --cache-type-v q4_0`

KV cache 量化。这是能开 96K 的关键——
不量化的话，96K 的 KV cache 本身就吃掉几 GB。

**代价**：极长上下文的精度略有下降。但实测对话质量没问题。

### `--parallel 1` —— 必须

`--parallel N` 会**切分** `-c`：

```
--parallel 2 + -c 98304  →  每槽 49152
```

Hermes 请求的上下文可能超单槽，就报超限。**固定 `--parallel 1`。**

### `--reasoning-budget 400` —— 防思考跑飞

脚本注释原文：

> Qwen3.5 thinking loops can run away. `--reasoning-budget` caps them.
> - `qwopus` : no cap needed (stops naturally around 600 chars)
> - `heretic` : budget 400 (stops at ~1500 chars, reasoning intact)

**两个模型行为不一样：**

| 模型 | 需要 budget 吗 | 原因 |
|---|---|---|
| qwopus | ❌ 不需要 | 自然停在 600 字符左右 |
| heretic | ✅ 需要 400 | 不设会一直想下去 |

`--reasoning-budget-message` 是撞到上限时注入的提示语，让它收尾：

```
Stop thinking and give the final answer now.
```

### `setsid nohup ... & disown`

**三重脱离。** 见下面「坑 2」。

### `--jinja --no-warmup`

- `--jinja`：用模型自带的 chat template（Qwen3.5 需要）
- `--no-warmup`：跳过预热，加快启动

---

## 接进 Hermes

### 配置

```yaml
# %LOCALAPPDATA%\hermes\config.yaml
model:
  default: "heretic4b"          # 或 qwopus4b
  provider: "custom"
  base_url: "http://127.0.0.1:8420/v1"
```

**三处必须对齐：**

| 项 | 脚本里 | 配置里 |
|---|---|---|
| 别名 | `--alias heretic4b` | `default: "heretic4b"` |
| 端口 | `--port 8420` | `base_url: ...:8420/v1` |
| 格式 | OpenAI 兼容 | `provider: "custom"` |

**别名不一致会报「模型不存在」。**

### 两个模型的配置切换

```yaml
# 用 qwopus（工具调用）
model:
  default: "qwopus4b"
  provider: "custom"
  base_url: "http://127.0.0.1:8400/v1"

# 用 heretic（无审查）
model:
  default: "heretic4b"
  provider: "custom"
  base_url: "http://127.0.0.1:8420/v1"
```

改完重启 Hermes。

---

## 实测性能

来自 `heretic.log` 的真实 `print_timing` 记录：

| 项目 | 数值 |
|---|---|
| 生成速度 | **54.87 ~ 67.90 tok/s** |
| prompt 处理 | 224 ~ 497 tok/s（小 prompt） |
| 单次生成 token 数 | 183 ~ 700 |

**对比 9B 模型（37~39 tok/s），4B 快约 70%。**

---

## 五个必须知道的坑

### 1. `--parallel N` 切分上下文

```
--parallel 2 + -c 98304  →  每槽 49152
```

Hermes 请求超单槽就失败。**固定 `--parallel 1`。**

### 2. 进程被 WSL 回收

**最坑的一个。** `wsl.exe -e bash -c "..."` 命令返回后，
WSL 会回收整个会话树——你测着一切正常，命令一结束服务就没了。

表现：Hermes 报 `Connection error`，但 `nvidia-smi` 显示显存还占着（僵死进程）。

**必须三重脱离：**

```bash
setsid nohup ./llama-server ... > log 2>&1 < /dev/null &
disown
```

三个都要：
- `setsid`：新会话，脱离控制终端
- `nohup`：忽略 SIGHUP
- `disown`：从 shell 作业表移除

**少了任何一个都可能被回收。**

### 3. `max_tokens` 不能太大

模型 `contextWindow = 98304`，如果 `max_tokens` 也设这么大，
输入+输出必然超限。

**建议 4096**，给输入留 94K 空间。

### 4. 思考链吃 token

Qwen3.5 是推理模型。`max_tokens` 设太小（比如 40）会出现：

```
content: ""
reasoning_content: "让我想想...（塞满）"
```

**这是模型行为，不是 bug。** 要么调大 `max_tokens`，
要么用 `--reasoning-budget` 限制思考量。

### 5. 一次只能跑一个

8GB 卡放不下两个模型（各约 6.6 GB）。

`start-local-model.sh` 的 `stop` 会按端口 kill：

```bash
pkill -f "llama-server.*84"    # 匹配 8400 和 8420
```

切换模型时先 `stop` 再 `start`。

---

## 快速验证

### 服务是否起来

```bash
curl -s http://127.0.0.1:8420/v1/models | head -c 200
```

### 能否正常对话

```bash
curl -s http://127.0.0.1:8420/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "heretic4b",
    "messages": [{"role":"user","content":"说三个字"}],
    "max_tokens": 50
  }'
```

### 显存占用

```bash
nvidia-smi --query-gpu=memory.used,memory.free --format=csv
```

正常应该在 6.6 GB 左右（96K 上下文 + 视觉）。

---

## 下载模型

模型来自 HuggingFace，4B 级别约 2.5 GB。

```bash
# 用 huggingface-cli
huggingface-cli download <repo> --local-dir models/

# 或直接 wget/curl 单文件
```

**注意**：`mmproj` 要单独下，不包含在主模型里。

下完校验 SHA256 再启动，免得读到半个文件。

---

## 和其他模型的关系

`USER.md`（角色卡）是**模型无关**的：

```
本地 heretic4b（无审查）  ┐
本地 qwopus4b（工具调用） ├──→  同一份 USER.md  ──→  同一个人格
云端 DeepSeek / Kimi     ┘
```

**换模型不换人格。**
显存不够就跑 4B，能力退一步，人设不变。

关于人格系统详见 [`personality-system.md`](personality-system.md)。

---

## 姊妹项目

9B 模型的完整方案（显存实测、上下文取舍、下载脚本）：

[DeepSeek9B-8GB-VRAM-Setup](https://github.com/Alexander390370/DeepSeek9B-8GB-VRAM-Setup)
