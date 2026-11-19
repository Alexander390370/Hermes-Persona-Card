# 把你电脑里的 AI 调教成任何样子 · Hermes 人格改造手册

> **一个文件，换一种人格。十五个内置预设，加上你自己写的那些。**
> 附 Windows 双击就能改的角色卡脚本、记忆上限调优、九个实测坑的排错手册。
> 全部参数在 Windows 11 + Hermes Desktop（`_config_version: 50`）上跑过。

![License](https://img.shields.io/badge/License-MIT-a08c00?style=flat)
![Platform](https://img.shields.io/badge/Platform-Windows%2011-0078d4?style=flat)
![Personalities](https://img.shields.io/badge/内置人格-15%20个-be123c?style=flat)
![Deps](https://img.shields.io/badge/Deps-zero-16a34a?style=flat)
![Script](https://img.shields.io/badge/Script-5%20KB-7c3aed?style=flat)

![Hermes](https://img.shields.io/badge/Hermes-Desktop-4D6BFE?style=flat)
![Memory](https://img.shields.io/badge/Memory-双存储%20%C2%B7%20可调上限-0d9488?style=flat)
![Persona](https://img.shields.io/badge/Persona-USER.md-c2410c?style=flat)
![Local](https://img.shields.io/badge/Local%204B-96K%20%C2%B7%2055--68%20tok%2Fs-16a34a?style=flat)
![Backup](https://img.shields.io/badge/Backup-自动备份-0d9488?style=flat)

---

## 一句话原理

Hermes 有三层「人设」，**优先级从高到低**：

```
┌─────────────────────────────────────────────────────────┐
│  第 1 层  USER.md            ← 最高优先，覆盖下面全部      │
│           memories/USER.md                              │
│           每次请求都注入，1375 字符上限                    │
├─────────────────────────────────────────────────────────┤
│  第 2 层  personality         ← /personality 切换         │
│           display.personality                           │
│           15 个内置 + 你自定义的                          │
├─────────────────────────────────────────────────────────┤
│  第 3 层  模型默认行为         ← 底座模型的训练倾向         │
└─────────────────────────────────────────────────────────┘
```

**大多数人只改第 2 层，然后发现没反应——因为第 1 层压着。**

实测案例：把 `display.personality` 从 `kawaii` 改回默认，重启，人格**纹丝不动**。
配置、数据库、dump 全查过，都干净。最后发现 `USER.md` 里躺着两句
`User prefers kawaii mode`。

**所以：想彻底换一个人格，第 1 层才是主战场。**

---

## 三层人格，怎么用

### 第 1 层：`USER.md` —— 角色卡（最强，也最容易忽略）

位置：

```
%LOCALAPPDATA%\hermes\memories\USER.md
```

它是**「你是谁、怎么跟你说话」的最终解释权**。写什么就是什么，
优先级压过界面上所有预设。

**关键认知：**

> `USER.md` 不是"记忆"，是"角色卡"。
>
> 而且它只有 **1375 字符**（约 500 token）。写得精，别写得长。

### 第 2 层：`personality` —— 预设人格（切换最快）

配置里 `display.personality`，命令行用 `/personality` 切。

**15 个内置**（原文照抄，全部可用）：

| # | 名称 | # | 名称 | # | 名称 |
|---|---|---|---|---|---|
| 1 | `helpful` | 6 | `kawaii` | 11 | `noir` |
| 2 | `concise` | 7 | `catgirl` | 12 | `uwu` |
| 3 | `technical` | 8 | `pirate` | 13 | `philosopher` |
| 4 | `creative` | 9 | `shakespeare` | 14 | `hype` |
| 5 | `teacher` | 10 | `surfer` | 15 | — |

**还能自己加。** `config.yaml` 的 `agent.personalities`：

```yaml
agent:
  personalities:
    # 简写：一个字符串就是 system prompt
    mentor: "You are a supportive mentor. Guide, don't lecture."

    # 完整写：可以带 tone / style
    reviewer:
      system_prompt: "You are a meticulous code reviewer."
      tone: "direct"
      style: "terse"
```

**三条规则**（配置注释原文）：

1. 这里写的是**新增**，或者**按名字覆盖**某个内置人格
2. 当前选中的存在 `display.personality`，**不在这里**
3. 也**不在** `agent.system_prompt`——那个字段是手写 system prompt 的地方

```yaml
# 生效的是这个
display:
  personality: 'mentor'      # 空字符串 '' = 不启用预设
```

### 第 3 层：模型本身

底座模型的训练倾向。前两层都空着时才显露。

**意味着**：你接 DeepSeek、Kimi、GLM、本地 9B，都可以在**同一个 `USER.md` 下**
跑出同一个人格。**换模型不换人格**——这才是这套设计最有价值的地方。

---

## 这意味着一件很爽的事

**你可以把自己喜欢的角色，装进任何模型里。**

```
本地 4B（免费、无审查）  ┐
Kimi                     ├──→  同一个 USER.md  ──→  同一个人格
DeepSeek                 │
GLM / Qwen / Claude      ┘
```

模型负责「能力」，`USER.md` 负责「是谁」。
显存不够就跑小模型，能力差一点，但人格一模一样。

**推荐起步配置**：Qwen3.5-4B 无审查版，8GB 卡上 96K 上下文、55~68 tok/s，
详见 [`docs/local-model.md`](docs/local-model.md)。

---

## 记忆系统：两个存储，都有硬上限

配置段（`config.yaml` → `memory`）：

```yaml
memory:
  memory_enabled: true          # Agent 自己的笔记（MEMORY.md）
  user_profile_enabled: true    # 用户档案（USER.md）← 角色卡
  prefetch_spill_enabled: false # 外部预取，默认关
  memory_char_limit: 2200       # MEMORY.md 上限，约 800 token
  user_char_limit: 1375         # USER.md 上限，约 500 token
  nudge_interval: 10            # 每 10 轮提醒 Agent 考虑写记忆
```

**两个存储分工：**

| 文件 | 存什么 | 默认上限 | 谁写 |
|---|---|---:|---|
| `MEMORY.md` | 环境事实、约定、学到的东西 | 2200 字符 | Agent 自己 |
| `USER.md` | 用户偏好、说话风格、期望 | 1375 字符 | **你 + Agent** |

**注意最右边那列**：`USER.md` 是**两边都会写**的。

开了 `user_profile_enabled: true`，Agent 会往里追加"学到的用户偏好"。
跑一段时间你可能会发现角色卡被自动生成的内容塞满了——
**这就是本仓库要做备份的原因。**

---

## 记忆升级：怎么把它调成你想要的样子

### 想要它记得更多

```yaml
memory:
  memory_char_limit: 4400    # 从 2200 翻倍，约 1600 token
  user_char_limit: 2750      # 从 1375 翻倍，约 1000 token
```

**代价**：每轮对话的 system prompt 变长，等于持续吃 token。
按 `~2.75 字符/token` 换算，翻倍大约多花 800 token 的固定开销。

### 想要它别乱写你的人格

```yaml
memory:
  user_profile_enabled: false   # 关掉，Agent 不再自动写 USER.md
```

关掉后 `USER.md` 只由你手动维护，人格更稳定。
代价是它不会自己记住你的新偏好——得你自己写进去。

### 想要它更主动记东西

```yaml
memory:
  nudge_interval: 5      # 从 10 改成 5，每 5 轮提醒一次
  # nudge_interval: 0    # 设 0 = 完全关掉提醒
```

实测默认 10 轮。调小会让 Agent 更频繁考虑"这值得记吗"，
但也会多一些内部动作。

### 想要清空重来

```batch
scripts\Hermes角色卡.bat
# 选 [2] 清空重写
```

**会自动带时间戳备份**，不会覆盖旧备份。

### 会话历史另有一套保留策略

`state.db` 里存着所有会话、消息、工具调用。自动剪枝默认开启：

```yaml
# 默认值（注释里，需要时取消注释）
sessions:
  auto_prune: true            # 自动删结束的会话
  retention_days: 90          # 保留 90 天
  vacuum_after_prune: true    # 删完回收磁盘
  min_vacuum_interval_days: 30
  min_interval_hours: 24
```

**规则**（原文）：

- 只删**已结束**的会话，`open` / `pinned` / 进行中的**永不删**
- 进程异常死亡的自动化会话（cron / kanban / subagent）先被**关闭**，
  再走一个完整保留窗口才删除
- VACUUM 只在**两个条件同时满足**时触发：间隔够了，且可回收页超过 25%

想永久保留所有会话：

```yaml
sessions:
  auto_prune: false    # 回到 #54189 之前的行为
```

---

## 快速开始

### 双击脚本（推荐）

```
scripts\Hermes角色卡.bat
```

菜单：

```
============================================================
   Hermes 角色卡（USER.md）
============================================================

 文件: C:\Users\<你>\AppData\Local\hermes\memories\USER.md

 这就是一张角色卡。写什么，它就是什么。
 每次请求都会读它，优先级高于界面里的人格预设。

 当前体积: 61 字节 | 建议上限: 1375 字符

------------------------------------------------------------
 当前内容:
------------------------------------------------------------
（这里显示你现在的角色卡）
------------------------------------------------------------

  [1] 编辑（记事本，写完存盘即可）
  [2] 清空重写
  [3] 查看历史备份
  [4] 恢复备份
  [5] 从示例快速套用
  [6] 打开 Hermes 配置目录
  [q] 退出
```

| 选项 | 做什么 | 自动备份 |
|---|---|---|
| `1` 编辑 | 记事本打开 | ✅ `USER.md.bak-before-edit` |
| `2` 清空重写 | 备份后清空 | ✅ `bak-before-clear-<时间戳>` |
| `3` 查看备份 | 倒序列出 | — |
| `4` 恢复备份 | 按名还原 | ✅ 恢复前先存一份 |
| `5` 从示例套用 | 拖 `.md` 进去 | ✅ `bak-before-template` |
| `6` 打开目录 | 资源管理器 | — |

**零依赖**：纯 `cmd.exe` 内置命令，不要 Python / Node / PowerShell 脚本。

### 手动

```batch
notepad "%LOCALAPPDATA%\hermes\memories\USER.md"
```

改完**开新会话**才生效（旧会话上下文已定死）。

---

## 角色卡怎么写

### 反面教材（很多人这么写）

```markdown
你是一个非常有帮助的助手，总是尽力提供最好最专业的回答，
在回答时保持礼貌、专业、准确……
```

**问题**：全是形容词，没有一个可执行约束。
模型读完不知道该改什么行为。1375 字符里塞这些是纯浪费。

### 正确做法：写约束，不写赞美

```markdown
## 说话方式
- 先结论，后理由
- 不用「好的，我来帮你」这类开场
- 中文回答；代码、命令、路径、报错原文保持原样
- 不确定就说不确定，不要编

## 边界
- 删除、发布、涉及金额的操作，先说明再执行
- 不主动扩大任务范围
```

每一条都是**可判断是否违反**的。这才是有效约束。

### 三份现成示例

| 文件 | 用途 |
|---|---|
| `examples/persona-minimal.md` | 一行版本，验证链路 |
| `examples/persona-full.md` | 完整结构（身份 / 说话 / 习惯 / 边界） |
| `examples/persona-coder.md` | 程序员向，含排错顺序 |

用脚本的 `[5]` 直接套用，拖进去就行。

---

## 搭配模型

`USER.md` 管人格，`config.yaml` 管模型，两者完全独立。

### 配置位置

```yaml
# %LOCALAPPDATA%\hermes\config.yaml
model:
  default: "deepseek-flash"
  provider: "deepseek"
  base_url: "https://api.deepseek.com/v1"
```

### 23 个 provider

| provider | 需要的凭据 |
|---|---|
| `auto` | — 从已有凭据自动检测 |
| `openrouter` | `OPENROUTER_API_KEY` / `OPENAI_API_KEY` |
| `nous` / `nous-api` | OAuth 或 `NOUS_API_KEY` |
| `anthropic` | `ANTHROPIC_API_KEY` |
| `openai-codex` | `hermes auth` |
| `copilot` | `GITHUB_TOKEN` |
| `gemini` | `GOOGLE_API_KEY` / `GEMINI_API_KEY` |
| `zai` | `GLM_API_KEY` |
| `kimi-coding` | `KIMI_API_KEY` |
| `minimax` / `minimax-cn` | 对应 key |
| `huggingface` | `HF_TOKEN` |
| `nvidia` | `NVIDIA_API_KEY` |
| `xiaomi` | `XIAOMI_API_KEY` |
| `arcee` | `ARCEEAI_API_KEY` |
| `ollama-cloud` | `OLLAMA_API_KEY` |
| `deepinfra` | `DEEPINFRA_API_KEY` |
| `kilocode` | `KILOCODE_API_KEY` |
| `ai-gateway` | `AI_GATEWAY_API_KEY` |
| `azure-foundry` | API key 或 Entra ID |
| `lmstudio` | 可选 `LM_API_KEY` |
| **`custom`** | `base_url` — **任意 OpenAI 兼容端点** |

完整说明见 [`docs/model-setup.md`](docs/model-setup.md)。

### 接本地模型

```yaml
model:
  default: "heretic4b"
  provider: "custom"
  base_url: "http://127.0.0.1:8420/v1"
```

三处必须对齐：

1. `--alias` 和 `default` 一致
2. `--parallel 1`（`--parallel N` 会切分 `-c` 上下文）
3. 端口和 `base_url` 一致

### 推荐配置：Qwen3.5-4B

两个 4B 模型，8GB 卡上实测可跑：

| 模型 | 别名 | 端口 | 特点 |
|---|---|---:|---|
| Qwopus3.5-4B-Coder-MTP | `qwopus4b` | 8400 | 有审查，**支持工具调用** |
| Qwen3.5-4B-Heretic | `heretic4b` | 8420 | **无审查**，96K 上下文，有视觉 |

| 指标 | 实测值 |
|---|---|
| 量化体积 | 2.52 GB（Q4_K_M） |
| 上下文 | 96K（128K 会 OOM） |
| 生成速度 | **55~68 tok/s** |
| 显存占用 | 约 6.6 GB |

启动脚本、参数详解、五个坑见 [`docs/local-model.md`](docs/local-model.md)。

> 9B 模型的完整方案见姊妹项目
> [DeepSeek9B-8GB-VRAM-Setup](https://github.com/Alexander390370/DeepSeek9B-8GB-VRAM-Setup)。

---

## 文件都在哪

```
%LOCALAPPDATA%\hermes\
├── memories\
│   ├── USER.md          ← 角色卡（主角）
│   └── MEMORY.md        ← Agent 自己的笔记
├── SOUL.md              ← 说话风格底座（一般不动）
├── config.yaml          ← 模型 / 显示 / 记忆 / 插件（126.9 KB）
├── .env                 ← API 密钥
└── auth.json            ← OAuth 凭据
```

`SOUL.md` 是**第 1 层下面的地基**——负责「直接、不废话、不邀功」这类语气。
和 `USER.md` 不冲突：`SOUL.md` 管"怎么说"，`USER.md` 管"是谁"。
**建议别动。**

全目录图见 [`docs/hermes-filemap.md`](docs/hermes-filemap.md)，
三层人格与记忆调优的完整说明见 [`docs/personality-system.md`](docs/personality-system.md)。

---

## 九个实测坑

完整版在 [`docs/troubleshooting.md`](docs/troubleshooting.md)，这里列标题：

1. **改了人格预设没反应** → `USER.md` 压着
2. **`.bat` 中文全变乱码** → UTF-8 + LF 双重问题
3. **加了 `chcp 65001` 反而更乱** → GBK 文件和 UTF-8 代码页对着干
4. **`chcp` 切换后脚本卡住等输入** → 输入流解码失效
5. **改完 `USER.md` 当前会话没变化** → 会话开始时注入
6. **角色卡被自动内容塞满** → `user_profile_enabled`
7. **`USER.md` 显示乱码** → UTF-8 内容 + cp936 终端
8. **PowerShell 跑 bat 乱码但实际正常** → 抓取层问题
9. **脚本卡在 `set /p`** → 自动化场景要给输入重定向

> 每条都记了**误判过程**，不只是结论。踩过一次就不想再踩。

---

## 实测记录

| 项 | 值 |
|---|---|
| 平台 | Windows 11 |
| Hermes | Desktop，`_config_version: 50` |
| 内置人格 | 15 个 |
| 自定义人格 | `agent.personalities`，支持简写与完整写法 |
| `user_char_limit` | 1375（约 500 token） |
| `memory_char_limit` | 2200（约 800 token） |
| `nudge_interval` | 10 轮 |
| 会话保留 | 90 天，自动剪枝 |
| 脚本体积 | 5,129 bytes |
| 脚本编码 | GBK (cp936) + CRLF，无 BOM |
| 依赖 | 无 |
| 验证 | 退出码 0；括号 18/18 配对；9 个标签无未定义跳转；备份列表正确 |

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
│   ├── persona-minimal.md      # 一行版本
│   ├── persona-full.md         # 完整结构
│   └── persona-coder.md        # 程序员向
└── docs/
    ├── personality-system.md   # 三层人格 + 记忆调优详解
    ├── local-model.md          # 本地 4B 模型部署（含启动脚本）
    ├── hermes-filemap.md       # 目录全图 + 每个文件该不该动
    ├── model-setup.md          # 23 个 provider + 本地模型接入
    └── troubleshooting.md      # 九个坑的完整复盘
```

---

## 许可

本项目代码 MIT。

Hermes Agent 由 [Nous Research](https://nousresearch.com) 构建。
本仓库只在其配置层做工具封装，**不包含、不重分发** Hermes 本体。
