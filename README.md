# Hermes 角色卡 · 一个文件换一个人格

> 把 Hermes Agent 的人格当成**一张可编辑的角色卡**来管：改 `USER.md` 就是换人格，
> 带备份、带还原、带一个双击就能用的 Windows 脚本。
> 全部路径和参数都在 Windows 11 + Hermes Desktop 上实测过。

![License](https://img.shields.io/badge/License-MIT-a08c00?style=flat)
![Platform](https://img.shields.io/badge/Platform-Windows%2011-0078d4?style=flat)
![Encoding](https://img.shields.io/badge/Encoding-GBK%20%2B%20CRLF-dc2626?style=flat)
![Deps](https://img.shields.io/badge/Deps-zero-16a34a?style=flat)
![Script](https://img.shields.io/badge/Script-2.5%20KB-7c3aed?style=flat)

![Hermes](https://img.shields.io/badge/Hermes-Desktop-4D6BFE?style=flat)
![Persona](https://img.shields.io/badge/Persona-USER.md-be123c?style=flat)
![Backup](https://img.shields.io/badge/Backup-auto-0d9488?style=flat)

---

## 这个项目解决什么问题

Hermes 有三层「人设」，**优先级从高到低**：

| 优先级 | 位置 | 作用 | 能否被覆盖 |
|---|---|---|---|
| **1（最高）** | `%LOCALAPPDATA%\hermes\memories\USER.md` | 用户档案，每次请求都注入 | — |
| 2 | `config.yaml` → `display.personality` | 界面里的人格预设 | 被 USER.md 覆盖 |
| 3（最低） | 模型默认行为 | 底座模型的训练倾向 | 被以上两者覆盖 |

**坑在这里**：很多人以为换了界面预设就改了人格，结果发现没反应——
因为 `USER.md` 里还留着旧的两三行字，把预设压死了。

实测案例：把 `display.personality` 从 `kawaii` 改回默认，重启 Hermes，人格**依然是 Kawai**。
根因不在配置、不在数据库、不在 dump，就在 `USER.md` 里两句
「User prefers kawaii mode」。

**这个仓库就是让这层变得可见、可编辑、可回滚。**

---

## 核心认知

> **`USER.md` 不是"记忆"，是"角色卡"。**
>
> 写什么，它就是什么。它比界面里所有人格预设都硬。

而且它很短——`user_char_limit` 默认 **1375 字符**（约 500 token）。
所以写的每一句都得算数，写废话就是浪费上下文。

---

## 快速开始

### 方式一：双击脚本（推荐）

```
scripts\Hermes角色卡.bat
```

菜单长这样：

```
============================================================
   Hermes 角色卡（USER.md）
============================================================

 文件: C:\Users\34246\AppData\Local\hermes\memories\USER.md

 这就是一张角色卡。写什么，它就是什么。
 每次请求都会读它，优先级高于界面里的人格预设。

------------------------------------------------------------
 当前内容:
------------------------------------------------------------
（这里显示你现在的角色卡）

------------------------------------------------------------

  [1] 编辑（记事本，写完存盘即可）
  [2] 清空重写
  [3] 查看历史备份
  [4] 恢复备份
  [q] 退出
```

**四个功能：**

| 选项 | 做什么 | 是否自动备份 |
|---|---|---|
| `1` 编辑 | 记事本打开 USER.md | ✅ `USER.md.bak-before-edit` |
| `2` 清空重写 | 先备份再清空，然后打开记事本 | ✅ `USER.md.bak-before-clear` |
| `3` 查看备份 | 列出所有 `.bak*` 文件 | — |
| `4` 恢复备份 | 输入文件名还原 | — |

**不依赖任何东西**：不用 Python、不用 Node、不用 PowerShell 脚本。
纯 `cmd.exe` 内置命令。

### 方式二：手动

```batch
notepad "%LOCALAPPDATA%\hermes\memories\USER.md"
```

写完后**开新会话**才读新内容（旧会话的上下文已经定死了）。

---

## 角色卡怎么写

### 最小可用

```markdown
你说话简短。一行问题一行答。
```

### 带身份

```markdown
你的名字是「阿鲸」。你说话带一点海边的松弛感。
每次回答先给结论，再给理由。
```

### 完整写法（推荐结构）

```markdown
## 身份
你的名字是「X」。你是一个 Y。

## 说话方式
- 先结论后细节
- 不用「好的，我来帮你」这类开场
- 中文回答，代码和命令保持原样

## 边界
- 不确定就说不确定，不要编
- 涉及金额、删除、发布的操作，先确认
```

### 反面教材

```markdown
你是一个非常有帮助的助手，总是尽力提供最好最专业的回答……
```

**问题**：全是形容词，没有可执行约束。模型读完不知道该改什么行为。
`user_char_limit` 只有 1375 字符，这类话占地方还不起作用。

---

## 搭配模型

`USER.md` 管人格，`config.yaml` 管模型。两者独立。

### 模型配置在哪

```
%LOCALAPPDATA%\hermes\config.yaml
```

关键段：

```yaml
model:
  default: "deepseek-flash"        # 默认模型
  provider: "deepseek"              # provider 选择
  base_url: "https://api.deepseek.com/v1"
```

### provider 支持列表（config.yaml 注释里的原文）

| provider | 需要什么 | 说明 |
|---|---|---|
| `auto` | — | 从凭据自动检测（默认） |
| `openrouter` | `OPENROUTER_API_KEY` / `OPENAI_API_KEY` | 聚合网关 |
| `nous` / `nous-api` | OAuth 或 `NOUS_API_KEY` | Nous Portal |
| `anthropic` | `ANTHROPIC_API_KEY` | Claude 直连 |
| `openai-codex` | `hermes auth` | OpenAI Codex |
| `copilot` | `GITHUB_TOKEN` | GitHub Copilot / Models |
| `gemini` | `GOOGLE_API_KEY` / `GEMINI_API_KEY` | Google AI Studio |
| `zai` | `GLM_API_KEY` | 智谱 GLM |
| `kimi-coding` | `KIMI_API_KEY` | Kimi / Moonshot |
| `minimax` / `minimax-cn` | 对应 API key | MiniMax 国际 / 国内 |
| `huggingface` | `HF_TOKEN` | HF Inference |
| `nvidia` | `NVIDIA_API_KEY` | NVIDIA NIM |
| `deepinfra` | `DEEPINFRA_API_KEY` | DeepInfra |
| `ai-gateway` | `AI_GATEWAY_API_KEY` | Vercel AI Gateway |
| `azure-foundry` | API key 或 Entra ID | Azure OpenAI |
| `lmstudio` | 可选 `LM_API_KEY` | 默认 `http://127.0.0.1:1234/v1` |
| **`custom`** | `base_url` | **任意 OpenAI 兼容端点** |

### 接本地模型

`custom` 是接 llama.cpp / vLLM / Ollama 的正确姿势：

```yaml
model:
  default: "deepseek9b"
  provider: "custom"
  base_url: "http://127.0.0.1:8440/v1"
```

启动 llama-server 时要对齐三件事：

1. **模型别名**（`--alias`）要和 `default` 一致
2. **上下文长度**（`-c`）要够，且注意 `--parallel N` 会切分上下文
3. **端口**要和 `base_url` 对上

> 本地模型接 Hermes 的完整参数（显存实测、上下文切分坑、进程被 WSL 回收）
> 见姊妹项目 [DeepSeek9B-8GB-VRAM-Setup](https://github.com/Alexander390370/DeepSeek9B-8GB-VRAM-Setup)。

### 凭据在哪

```
%LOCALAPPDATA%\hermes\.env
```

实测键名（**值是 API key，不要提交**）：

```ini
DEEPSEEK_API_KEY=sk-...
DEEPSEEK_BASE_URL=https://api.deepseek.com/v1
KIMI_CN_API_KEY=sk-...
DASHSCOPE_API_KEY=sk-...
DASHSCOPE_BASE_URL=...
HERMES_CUSTOM_DEEPSEEK_API_KEY=sk-...
```

---

## 其他相关文件

```
%LOCALAPPDATA%\hermes\
├── memories\
│   ├── USER.md           ← 角色卡（本项目主角）
│   └── MEMORY.md         ← Agent 自己的笔记，上限 2200 字符
├── SOUL.md               ← 底座行为准则，通常不用动
├── config.yaml           ← 模型、显示、记忆、插件全部配置
├── .env                  ← API 密钥
└── auth.json             ← OAuth 凭据
```

### `SOUL.md` 是什么

```markdown
You are Hermes Agent, built by Nous Research. Be direct: match the length of
your reply to the weight of the ask — a one-line question gets a one-line answer,
and finished work gets a short report of what changed, what's verified, and what's
left, never a replay of the process. No filler ("Great question," "I'd be happy to"),
no restating the request back...
```

这是**说话风格的底座**——负责「直接、不废话、不邀功」。
和 `USER.md` 不冲突：`SOUL.md` 管"怎么说"，`USER.md` 管"是谁"。

**建议不要动它**，除非你明确想改掉 Hermes 的默认语气。

### 记忆的上限

```yaml
memory:
  memory_enabled: true
  user_profile_enabled: true
  memory_char_limit: 2200      # MEMORY.md 上限，约 800 token
  user_char_limit: 1375        # USER.md 上限，约 500 token
  nudge_interval: 10           # 每 10 轮提醒 Agent 考虑写记忆
```

**`user_char_limit: 1375`** 就是角色卡的硬上限。
超了会被截断——所以**写得精，别写得长**。

---

## 五个必须知道的坑

### 1. `.bat` 文件必须是 GBK + CRLF

中文 `.bat` 用 UTF-8 存，`cmd.exe` 按 GBK 解码 → 中文乱码 → 括号被吞 → 报错
`Missing closing '}'` 或 `'tepad' is not recognized`。

**正确做法：**

```powershell
$text = Get-Content '源.bat' -Raw -Encoding UTF8
[System.IO.File]::WriteAllText('目标.bat', $text, [System.Text.Encoding]::GetEncoding(936))
# 同时确保 CRLF 换行
```

**不要**同时加 `chcp 65001`——那是给 UTF-8 文件用的，混用会双重乱码。

### 2. 改完要开新会话

`USER.md` 在会话开始时注入。改文件后**当前会话不会变**，必须新建会话。

### 3. 界面预设改不动人格

`display.personality` 的优先级低于 `USER.md`。
如果改了预设没反应，**先去翻 `USER.md`**，九成是它在压制。

### 4. `USER.md` 会被 Agent 自己写

开了 `user_profile_enabled: true` 后，Agent 会往里追加"用户偏好"。
一段时间后你会发现角色卡被塞满了自动生成的内容——
**这就是要备份的原因**。

### 5. 备份命名有讲究

脚本用 `USER.md.bak-before-edit` / `.bak-before-clear` 这种**固定名**覆盖式备份。
需要多版本快照时手动带时间戳：

```batch
copy "%LOCALAPPDATA%\hermes\memories\USER.md" ^
     "%LOCALAPPDATA%\hermes\memories\USER.md.bak-%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%"
```

---

## 实测记录

| 项 | 值 |
|---|---|
| 平台 | Windows 11 |
| Hermes | Desktop（配置 `_config_version: 50`） |
| 脚本体积 | 2,502 bytes |
| 脚本编码 | GBK (cp936) + CRLF，无 BOM |
| 依赖 | 无（纯 cmd 内置） |
| 验证 | 退出码 0，菜单渲染正常，1/2/3/4/q 全部可达 |
| `config.yaml` 体积 | 126.9 KB |
| `user_char_limit` | 1375 |
| `memory_char_limit` | 2200 |

---

## 目录结构

```
.
├── README.md
├── LICENSE
├── .gitignore
├── .gitattributes
├── scripts/
│   └── Hermes角色卡.bat        # 主脚本（GBK + CRLF）
├── examples/
│   ├── persona-minimal.md      # 最小角色卡
│   ├── persona-full.md         # 完整结构示例
│   └── persona-coder.md        # 程序员向
└── docs/
    ├── hermes-filemap.md       # Hermes 目录全图
    ├── model-setup.md          # 模型与 provider 详解
    └── troubleshooting.md      # 排错手册
```

---

## 许可

本项目代码 MIT。

Hermes Agent 由 [Nous Research](https://nousresearch.com) 构建，本项目只是在其配置层做工具封装，不包含 Hermes 本体。
