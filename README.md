# 把你电脑里的 AI 调教成任何样子 · Hermes 人格改造手册

> **一个文件，换一种人格。十五个内置预设，加上你自己写的那些。**
> 从下载安装到本地模型，一步一步来。附 Windows 双击就能改的角色卡脚本。
> 全部参数在 Windows 11 + Hermes v0.22.0 上实测。

![License](https://img.shields.io/badge/License-MIT-a08c00?style=flat)
![Platform](https://img.shields.io/badge/Platform-Windows%2011-0078d4?style=flat)
![Personalities](https://img.shields.io/badge/内置人格-15%20个-be123c?style=flat)
![Deps](https://img.shields.io/badge/Deps-zero-16a34a?style=flat)
![Script](https://img.shields.io/badge/Script-5%20KB-7c3aed?style=flat)

![Hermes](https://img.shields.io/badge/Hermes-v0.22.0-4D6BFE?style=flat)
![Memory](https://img.shields.io/badge/Memory-双存储%20%C2%B7%20可调上限-0d9488?style=flat)
![Persona](https://img.shields.io/badge/Persona-USER.md-c2410c?style=flat)
![Local](https://img.shields.io/badge/Local%204B-96K%20%C2%B7%2055--68%20tok%2Fs-16a34a?style=flat)

---

# 第一部分 · 小白也能上手（30 分钟）

> 这一部分假设你**什么都没装过**。跟着做就行。
> 装过 Hermes 的可以跳到 [第五步](#第五步换个你喜欢的性格)。

## 第一步：装 Hermes

### 1.1 下载

去 **https://nousresearch.com** 下载 Windows 版安装包。

装完的目录结构：

```
C:\Users\<你>\AppData\Local\hermes\
├── bin\hermes.exe        ← 命令行工具
├── hermes-agent\         ← 本体
├── config.yaml           ← 配置文件
├── memories\             ← 角色卡和记忆
└── desktop\              ← 桌面界面
```

### 1.2 验证装好了

打开 **PowerShell**（开始菜单搜 `powershell`），输入：

```powershell
& "$env:LOCALAPPDATA\hermes\bin\hermes.exe" --version
```

应该看到类似：

```
Hermes Agent v0.22.0+40.g6e84ce6 (2026.9.24) · stable
Install directory: C:\Users\<你>\AppData\Local\hermes\hermes-agent
Python: 3.14.7
```

**看到版本号就成功了。**

> 如果提示「找不到命令」，说明装的路径不对，或者需要重开一个 PowerShell 窗口。

### 1.3 第一次启动

双击桌面上的 Hermes 图标，或者：

```powershell
& "$env:LOCALAPPDATA\hermes\bin\hermes.exe" chat
```

第一次会跳出**设置向导**。

## 第二步：配一个模型

Hermes 需要一个大模型才能说话。三个选项，按你的情况挑：

### 选项 A：用云端 API（最省事，推荐新手）

需要有 API key。以 DeepSeek 为例：

1. 去 **https://platform.deepseek.com** 注册，拿一个 API key（`sk-` 开头）
2. 打开配置文件：

```powershell
notepad "$env:LOCALAPPDATA\hermes\.env"
```

3. 加一行：

```ini
DEEPSEEK_API_KEY=sk-你的密钥
```

4. 改模型配置：

```powershell
notepad "$env:LOCALAPPDATA\hermes\config.yaml"
```

找到 `model:` 这一段，改成：

```yaml
model:
  default: "deepseek-chat"
  provider: "deepseek"
  base_url: "https://api.deepseek.com/v1"
```

5. 重启 Hermes

### 选项 B：用设置向导（图形化）

```powershell
& "$env:LOCALAPPDATA\hermes\bin\hermes.exe" setup model
```

会出来一个交互式菜单，按提示选 provider、填 key。

### 选项 C：跑本地模型（不花钱，需要显卡）

见 [第二部分 · 本地模型](#第二部分--本地模型不花钱但要显卡)。
**新手先跳过，等前面跑通了再回来。**

## 第三步：说第一句话

重启 Hermes 后，发一句：

```
你好，介绍一下你自己
```

能正常回复，说明**链路通了**。

## 第四步：找到你的角色卡

这是整个手册的核心。打开这个文件：

```powershell
notepad "$env:LOCALAPPDATA\hermes\memories\USER.md"
```

里面可能有内容，也可能空的。

**这个文件就是"角色卡"。写什么，AI 就是什么。**

## 第五步：换个你喜欢的性格

### 方法一：双击脚本（最省事）

下载本仓库，解压，双击：

```
scripts\Hermes角色卡.bat
```

会看到菜单：

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
（显示你现在的角色卡）
------------------------------------------------------------

  [1] 编辑（记事本，写完存盘即可）
  [2] 清空重写
  [3] 查看历史备份
  [4] 恢复备份
  [5] 从示例快速套用
  [6] 打开 Hermes 配置目录
  [q] 退出
```

**第一次用，按 `5`，然后把你想要的示例文件拖进窗口。**

仓库里带了三份：

| 文件 | 适合 |
|---|---|
| `examples/persona-minimal.md` | 先试试水 |
| `examples/persona-full.md` | 完整角色卡 |
| `examples/persona-coder.md` | 写代码用 |

### 方法二：手动改

用记事本打开 `USER.md`，写几行：

```markdown
## 说话方式
- 先结论，后理由
- 不用「好的，我来帮你」这类开场
- 中文回答；代码和命令保持原样
- 不确定就说不确定，不要编
```

存盘，**开一个新会话**（旧的不会变），就生效了。

### 方法三：用预设人格（最快）

Hermes 自带 15 个性格。在对话里输入斜杠命令：

```
/personality kawaii
```

15 个可选：

```
helpful  concise  technical  creative  teacher
kawaii   catgirl  pirate     shakespeare  surfer
noir     uwu      philosopher  hype
```

> **注意**：如果 `USER.md` 里有内容，会盖住预设。
> 想让预设生效，先用脚本 `[2]` 清空 `USER.md`。

## 第六步：验证成功

再发一句话，看看性格变了没有。

**变了 → 恭喜，你已经掌握了这套东西的核心。**

---

## 小白常见问题

**Q：改完没反应？**

A：两个原因——

1. **没开新会话**。`USER.md` 只在会话开始时读一次。关掉当前会话，新建一个。
2. **`USER.md` 里还有旧内容**。它优先级最高，盖住了你改的预设。用脚本 `[2]` 清空。

**Q：脚本双击闪一下就没了？**

A：说明出错了。在 PowerShell 里跑一遍能看到报错：

```powershell
cd 到脚本所在目录
.\Hermes角色卡.bat
```

**Q：`USER.md` 能写多长？**

A：**1375 字符**（约 500 字）。超了会被截断。写得精，别写得长。

**Q：改了会影响以前的对话吗？**

A：不会。旧会话的上下文已经定下来了，只有新会话才用新的角色卡。

**Q：能不能不同会话用不同人格？**

A：可以。改 `USER.md` 后开新会话就是新人格，旧会话保持原样。

---

# 第二部分 · 本地模型（不花钱，但要显卡）

> 有 8GB 显存的独立显卡就能跑。没有的话用云端 API 也一样。

## 为什么推荐 4B

| 指标 | 值 |
|---|---|
| 量化体积 | **2.52 GB**（Q4_K_M） |
| 上下文 | **96K** |
| 视觉 | ✅ 支持 |
| 审查 | **无审查** |
| 生成速度 | **55~68 tok/s** |
| 显存占用 | 约 6.6 GB |

**4B 的好处是"够用且省"**：8GB 卡上能开 96K 上下文还留 1.3GB 余量，比 9B 快约 70%。

## 两个模型，按需选

8GB 卡**同时只能跑一个**。

| 模型 | 别名 | 端口 | 特点 | 用途 |
|---|---|---:|---|---|
| Qwopus3.5-4B-Coder-MTP | `qwopus4b` | **8400** | 有审查，**支持工具调用** | 写代码、日常 |
| Qwen3.5-4B-Heretic | `heretic4b` | **8420** | **无审查**，有视觉 | 自由对话、角色扮演 |

> 想要它帮你读文件、跑命令 → `qwopus`
> 想要不受限 + 能看图 → `heretic`

## 下载模型

两个模型共 4 个文件：

| 文件 | 大小 |
|---|---:|
| `Qwen35-4B-Heretic-Q4_K_M.gguf` | 2,707,514,720（2.52 GB） |
| `Qwen3.5-4B-heretic.mmproj-Q8_0.gguf` | 366,894,720（0.34 GB） |
| `Qwopus3.5-4B-Coder-MTP-Q4_K_M.gguf` | 2,783,446,560（2.59 GB） |
| `Qwopus3.5-4B-Coder-MTP.mmproj-F32.gguf` | 675,568,704（0.63 GB） |

**`mmproj` 是视觉投影，不装就只能读文字。**

下载完**校验 SHA256** 再启动，免得读到半个文件。

## 启动脚本

完整脚本见 [`docs/local-model.md`](docs/local-model.md)，核心参数：

```bash
setsid nohup ./llama-server \
    -m "$model" \
    -mm "$mmproj" \
    --host 0.0.0.0 --port "$port" \
    -ngl 99 -fa on -c 98304 \
    --cache-type-k q4_0 --cache-type-v q4_0 \
    --parallel 1 --fit off --jinja --no-warmup \
    --reasoning-budget 400 \
    --alias "$name" \
    > log.txt 2>&1 < /dev/null &
disown
```

用法：

```bash
./start-local-model.sh qwopus    # 端口 8400
./start-local-model.sh heretic   # 端口 8420
./start-local-model.sh stop      # 停止
./start-local-model.sh status    # 查看
```

## 接进 Hermes

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

改完重启 Hermes。

## 五个坑（都踩过）

1. **`--parallel N` 会切分上下文** → 固定 `--parallel 1`
2. **进程被 WSL 回收** → `setsid nohup & disown` 三重脱离
3. **`max_tokens` 不能太大** → 建议 4096
4. **思考链吃 token** → 用 `--reasoning-budget` 限制
5. **一次只能跑一个** → 切换先 `stop`

详细说明见 [`docs/local-model.md`](docs/local-model.md)。

---

# 第三部分 · 全链路原理

> 前面跑通了，再看这部分会清楚很多。

## 三句话讲完

1. **模型负责「能力」** —— 接什么模型，能力就到什么程度
2. **`USER.md` 负责「是谁」** —— 换文件就是换人格
3. **两者独立** —— 换模型不换人格

## 三层人格结构

Hermes 的人格由三层叠加，**优先级从高到低**：

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

### 为什么第 1 层最强

`USER.md` 是**每次请求都拼进 system prompt 的文本**。拼接顺序：

```
[SOUL.md 语气底座]
[personality 预设内容]      ← 第 2 层
[USER.md 内容]              ← 第 1 层，在这
[工具定义 / 会话历史 / 用户消息]
```

后出现的内容对模型行为影响更直接。而且 `USER.md` 用的是"用户档案"的语义
（"这个用户是谁、喜欢什么"），模型会当作事实接受。

**所以：想彻底换人格，必须改 `USER.md`；只改预设没用。**

### 实测案例

把 `display.personality` 从 `kawaii` 改回默认，重启，人格**纹丝不动**。
配置、数据库、dump 全查过，都干净。最后发现 `USER.md` 里躺着两句
`User prefers kawaii mode`。

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

## 记忆系统

### 两个存储

| 文件 | 存什么 | 默认上限 | 谁写 |
|---|---|---:|---|
| `MEMORY.md` | 环境事实、约定、学到的东西 | 2200 字符 | Agent 自己 |
| `USER.md` | 用户偏好、说话风格、期望 | 1375 字符 | **你 + Agent** |

**注意右边**：`USER.md` 是**两边都会写**的。

开了 `user_profile_enabled: true`，Agent 会往里追加"学到的用户偏好"。
跑一段时间你可能会发现角色卡被自动生成的内容塞满了——
**这就是本仓库要做备份的原因。**

### 配置

```yaml
memory:
  memory_enabled: true          # MEMORY.md 总开关
  user_profile_enabled: true    # USER.md 自动写入
  memory_char_limit: 2200       # 约 800 token
  user_char_limit: 1375         # 约 500 token
  nudge_interval: 10            # 每 10 轮提醒写记忆
```

### 四个调优方案

| 想要 | 怎么改 | 代价 |
|---|---|---|
| 记得更多 | `*_char_limit` 翻倍 | 固定开销从 1300 → 2600 token |
| 人格别被改 | `user_profile_enabled: false` | 不会自动记偏好 |
| 更主动记忆 | `nudge_interval: 10 → 5` | 多些内部动作 |
| 完全重置 | 脚本 `[2]` | 带时间戳备份 |

### 会话历史保留

`state.db` 存所有会话。默认自动剪枝：

| 项 | 默认值 |
|---|---|
| `auto_prune` | `true` |
| `retention_days` | `90` |

**永不删除的**：`open` / `pinned` / `in-progress` 三类会话。

永久保留所有会话：

```yaml
sessions:
  auto_prune: false
```

## 自定义人格预设

`config.yaml` → `agent.personalities`：

```yaml
agent:
  personalities:
    # 简写：一个字符串就是 system prompt
    mentor: "You are a supportive mentor. Guide, don't lecture."

    # 完整：可带 tone / style
    reviewer:
      system_prompt: "You are a meticulous code reviewer."
      tone: "direct"
      style: "terse"
```

**三条规则**（配置注释原文）：

1. 这里写的是**新增**，或**按名字覆盖**某个内置人格
2. 当前选中的存在 `display.personality`，**不在这里**
3. 也**不在** `agent.system_prompt`——那个字段是手写 system prompt 的地方

```yaml
display:
  personality: 'mentor'      # 空字符串 '' = 不启用预设
```

## 文件都在哪

```
%LOCALAPPDATA%\hermes\
├── bin\hermes.exe       ← CLI
├── hermes-agent\        ← 本体（git 安装）
├── memories\
│   ├── USER.md          ← 角色卡（主角）
│   └── MEMORY.md        ← Agent 的笔记
├── SOUL.md              ← 说话风格底座（一般不动）
├── config.yaml          ← 全部配置（126.9 KB）
├── .env                 ← API 密钥
└── auth.json            ← OAuth 凭据
```

**`SOUL.md` 是什么**：说话风格的地基，负责"直接、不废话、不邀功"。
和 `USER.md` 不冲突——`SOUL.md` 管"怎么说"，`USER.md` 管"是谁"。
**建议别动。**

完整目录图见 [`docs/hermes-filemap.md`](docs/hermes-filemap.md)。

---

# 附录

## 角色卡怎么写

### 反面教材

```markdown
你是一个非常有帮助的助手，总是尽力提供最好最专业的回答，
在回答时保持礼貌、专业、准确……
```

**问题**：全是形容词，没有一个可执行约束。模型读完不知道该改什么行为。
1375 字符里塞这些是纯浪费。

### 正确做法：写约束，不写赞美

```markdown
## 说话方式
- 先结论，后理由
- 不用「好的，我来帮你」这类开场
- 中文回答；代码、命令、路径、报错原文保持原样
- 不确定就说不确定，不要编

## 边界
- 删除、发布、涉及金额的操作，先说明再执行
```

每一条都**可判断是否违反**。这才是有效约束。

### 字符预算怎么分

| 部分 | 建议占比 |
|---|---:|
| 身份 | 15% |
| 说话方式 | 35% |
| 工作习惯 | 25% |
| 边界 | 20% |
| 其他 | 5% |

## 23 个 provider

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

## 九个实测坑

完整版在 [`docs/troubleshooting.md`](docs/troubleshooting.md)：

1. 改了人格预设没反应 → `USER.md` 压着
2. `.bat` 中文全变乱码 → UTF-8 + LF 双重问题
3. 加了 `chcp 65001` 反而更乱 → 编码对着干
4. `chcp` 切换后脚本卡住等输入 → 输入流解码失效
5. 改完 `USER.md` 当前会话没变化 → 会话开始时注入
6. 角色卡被自动内容塞满 → `user_profile_enabled`
7. `USER.md` 显示乱码 → UTF-8 内容 + cp936 终端
8. PowerShell 跑 bat 乱码但实际正常 → 抓取层问题
9. 脚本卡在 `set /p` → 自动化要给输入重定向

## 脚本功能表

| 选项 | 做什么 | 自动备份 |
|---|---|---|
| `1` 编辑 | 记事本打开 | ✅ `bak-before-edit` |
| `2` 清空重写 | 备份后清空 | ✅ `bak-before-clear-<时间戳>` |
| `3` 查看备份 | 倒序列出 | — |
| `4` 恢复备份 | 按名还原 | ✅ 恢复前先存一份 |
| `5` 从示例套用 | 拖 `.md` 进去 | ✅ `bak-before-template` |
| `6` 打开目录 | 资源管理器 | — |

**零依赖**：纯 `cmd.exe` 内置命令。

## 实测记录

| 项 | 值 |
|---|---|
| 平台 | Windows 11 |
| Hermes | v0.22.0+40.g6e84ce6（2026.9.24） |
| 安装方式 | git（`AppData\Local\hermes\hermes-agent`） |
| Python | 3.14.7 |
| 内置人格 | 15 个 |
| `user_char_limit` | 1375（约 500 token） |
| `memory_char_limit` | 2200（约 800 token） |
| 脚本体积 | 4,973 bytes |
| 脚本编码 | GBK (cp936) + CRLF，无 BOM |
| 依赖 | 无 |

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
    ├── local-model.md          # 本地 4B 部署（含完整脚本）
    ├── hermes-filemap.md       # 目录全图
    ├── model-setup.md          # 23 个 provider 详解
    └── troubleshooting.md      # 九个坑的完整复盘
```

## 许可

本项目代码 MIT。

Hermes Agent 由 [Nous Research](https://nousresearch.com) 构建。
本仓库只在其配置层做工具封装，**不包含、不重分发** Hermes 本体。
