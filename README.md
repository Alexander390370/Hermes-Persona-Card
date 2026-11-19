# 一键改写 Hermes 人格 · 自定义角色卡 + 长期记忆调优

> **Hermes 自带的人格预设只是设置里的一个下拉框——谁都能点。**
> **但真正决定"它是谁"的那个文件，藏在 `memories\USER.md` 里，优先级压过所有预设。**
> 本项目给这个文件配了一个双击就能用的脚本：备份、还原、套用模板，全程零依赖。
> 外加长期记忆的上限调优与自动剪枝策略。

![License](https://img.shields.io/badge/License-MIT-a08c00?style=flat)
![Platform](https://img.shields.io/badge/Platform-Windows%2011-0078d4?style=flat)
![Deps](https://img.shields.io/badge/Deps-zero-16a34a?style=flat)
![Script](https://img.shields.io/badge/Script-5%20KB-7c3aed?style=flat)
![Backup](https://img.shields.io/badge/Backup-6%20种自动备份-16a34a?style=flat)

![Hermes](https://img.shields.io/badge/Hermes-v0.22.0-4D6BFE?style=flat)
![Persona](https://img.shields.io/badge/Persona-一键改写-c2410c?style=flat)
![Memory](https://img.shields.io/badge/Memory-1375%20%E5%AD%97%E7%AC%A6%E4%B8%8A%E9%99%90-0d9488?style=flat)
![Local](https://img.shields.io/badge/Local%204B-96K%20%C2%B7%2055--68%20tok%2Fs-16a34a?style=flat)

---

## ⬇ 直接下载（不用 git clone）

| 包 | 内容 | 大小 | 下载 |
|---|---|---:|---|
| **Lite 版** | 脚本 + 三份模板 + 说明，**解压双击就能用** | 4.9 KB | [**下载**](https://github.com/Alexander390370/Hermes-Persona-Card/releases/download/v1.0.0/Hermes-Persona-Card-Lite-v1.0.0.zip) |
| 完整版 | 全部文档 + 示例 + 脚本 | 30.4 KB | [下载](https://github.com/Alexander390370/Hermes-Persona-Card/releases/download/v1.0.0/Hermes-Persona-Card-v1.0.0.zip) |

**只想改人格 → 下 Lite 版就够。** 解压后：

```
Hermes角色卡.bat        ← 双击运行
persona-minimal.md     ← 一行版本
persona-full.md        ← 完整角色卡
persona-coder.md       ← 写代码用
使用说明.md
```

打开脚本按 `5`，把 `persona-full.md` 拖进窗口，开新会话就换人格了。

> 全部版本见 [Releases](https://github.com/Alexander390370/Hermes-Persona-Card/releases)

---

## 这个项目解决什么

Hermes 有三层"人设"，**优先级从高到低**：

```
┌─────────────────────────────────────────────────────────┐
│  第 1 层  memories\USER.md   ← 最高优先，压过全部预设      │
│           每次请求注入 system prompt                      │
│           只有 1375 字符，写什么就是什么                    │
│                              ★ 本项目的主战场             │
├─────────────────────────────────────────────────────────┤
│  第 2 层  display.personality  ← 设置里的下拉框            │
│           15 个内置 + 可自定义                            │
│           ⚠ 有 USER.md 在，改了也没用                     │
├─────────────────────────────────────────────────────────┤
│  第 3 层  模型训练倾向         ← 前两层都空着才显露         │
└─────────────────────────────────────────────────────────┘
```

**关键点：绝大多数人只动第 2 层（那个下拉框），然后发现没反应——因为第 1 层压着。**

实测过的例子：把 `display.personality` 从 `kawaii` 改回默认，重启，人格**纹丝不动**。
配置、数据库、dump 全查过，都是干净的。最后发现 `USER.md` 里躺着两句
`User prefers kawaii mode`。

**所以真正的自定义入口是 `USER.md`。本项目就是给它做一套顺手的工具。**

---

## 为什么不用 Hermes 自带的人格设置

Hermes 自带的 15 个预设（`helpful` / `concise` / `kawaii` / `catgirl` …）确实能用，
但它们有几个硬限制：

| 问题 | 说明 |
|---|---|
| **优先级最低** | 有 `USER.md` 在，预设形同虚设 |
| **改不了细节** | 只能选一个，不能写"先结论后理由"这种具体约束 |
| **要进设置界面** | 每次调都得翻配置或敲命令 |
| **没有版本管理** | 改了就是改了，回不去 |
| **会被 Memory 冲掉** | Agent 自动写入的内容会挤占效果 |

**而 `USER.md` 没有这些限制**——它就是纯文本，写什么是什么。

**本项目的 bat 脚本解决的是「怎么把这件事做得不像在改配置文件」：**

- 双击就能编辑，不用记路径
- 每次改动**自动备份**，改坏了能还原
- 有三份现成模板，拖进去就换人格
- 直接显示当前体积，防止超 1375 字符上限
- 能看到历史所有版本，随时回滚

---

## 脚本能做什么

```
scripts\Hermes角色卡.bat        ← 双击运行
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
（实时显示你现在的角色卡全文）
------------------------------------------------------------

 相关文件:
   SOUL.md    存在（说话风格底座，一般不动）
   config.yaml 存在（模型与显示设置）
------------------------------------------------------------

  [1] 编辑（记事本，写完存盘即可）
  [2] 清空重写
  [3] 查看历史备份
  [4] 恢复备份
  [5] 从示例快速套用
  [6] 打开 Hermes 配置目录
  [q] 退出
```

### 六个功能，六种自动备份

| 选项 | 做什么 | 备份文件名 |
|---|---|---|
| `1` 编辑 | 记事本直接改 | `USER.md.bak-before-edit` |
| `2` 清空重写 | 先存旧内容再清空 | `USER.md.bak-before-clear-<时间戳>` |
| `3` 查看备份 | 按时间倒序列出全部 | — |
| `4` 恢复备份 | 按名回滚（恢复前再存一份当前） | `USER.md.bak-before-restore` |
| `5` 从示例套用 | 把 `.md` 拖进窗口 | `USER.md.bak-before-template` |
| `6` 打开目录 | 资源管理器跳转 | — |

**任何一次改动都有退路。** 这是自带设置界面做不到的。

### 零依赖

纯 `cmd.exe` 内置命令（`copy` / `type` / `dir` / `set /p`）。
**不需要** Python、Node、PowerShell 脚本、任何第三方工具。

拷到任何 Windows 机器上都能跑。

### 一个真实的技术细节

脚本本身是 **GBK (cp936) + CRLF**（中文 `.bat` 的硬要求），
但 `USER.md` 是 **UTF-8**。

如果直接 `type "%TARGET%"`，在 cp936 终端里中文会变乱码。
本脚本用 PowerShell 做一次转码输出：

```batch
powershell -NoProfile -Command "$c=Get-Content -LiteralPath '%TARGET%' -Raw -Encoding UTF8; [Console]::OutputEncoding=[Text.Encoding]::GetEncoding(936); Write-Output $c" 2>nul
if errorlevel 1 type "%TARGET%" 2>nul
```

**为什么不 `chcp 65001`？** 实测发现：`chcp` 切换会破坏标准输入流的解码，
后面的 `set /p` 收不到输入，整张菜单就废了。

这个坑记在 [`docs/troubleshooting.md`](docs/troubleshooting.md) 第 4 条。

---

## 长期记忆：第二个重点

`USER.md` 不是孤立的。它属于 Hermes 的**持久记忆系统**，和 `MEMORY.md` 配对工作。

### 两个存储

| 文件 | 语义 | 默认上限 | 谁写 |
|---|---|---:|---|
| **`USER.md`** | 用户画像：偏好、风格、期望 | **1375 字符** | **你 + Agent** |
| `MEMORY.md` | Agent 自己的笔记：环境事实、约定 | 2200 字符 | Agent |

**两者都注入 system prompt**，但 `USER.md` 的语义优先级更高。

### 配置全貌

```yaml
# %LOCALAPPDATA%\hermes\config.yaml
memory:
  memory_enabled: true          # MEMORY.md 总开关
  user_profile_enabled: true    # ← USER.md 自动写入开关
  prefetch_spill_enabled: false # 外部预取
  memory_char_limit: 2200       # 约 800 token
  user_char_limit: 1375         # 约 500 token
  nudge_interval: 10            # 每 10 轮提醒写记忆
```

**换算比例**（配置注释原文）：约 **2.75 字符 = 1 token**，模型无关。

所以这 1750 token 是**每一轮对话的固定开销**。

### ⚠ 最重要的一条：Agent 会偷偷改你的角色卡

看 `user_profile_enabled: true` 那一行。

开着它，Agent 会往 `USER.md` 里**追加"学到的用户偏好"**。

跑一段时间你会发现角色卡里出现自己没写过的句子，比如：

```markdown
- User prefers concise answers
- User works with Python on Windows
```

**这些会挤占你的角色卡空间**（只有 1375 字符），严重的会把你的设定顶掉。

**这就是本脚本要做备份的核心原因。**

三种应对：

| 做法 | 效果 |
|---|---|
| `user_profile_enabled: false` | Agent 不再自动写，人格最稳 |
| 定期用脚本 `[3]` 检查 + `[4]` 回滚 | 保留自动记忆但可控 |
| 每次改完先 `[1]` 备份 | 出问题能立刻回退 |

### 记忆调优四方案

| 我想要 | 改哪里 | 代价 |
|---|---|---|
| **记得更多** | `memory_char_limit: 4400`<br>`user_char_limit: 2750` | 固定开销 1300 → 2600 token |
| **人格别被改** | `user_profile_enabled: false` | 不会自动记偏好，得自己写 |
| **更主动记忆** | `nudge_interval: 10 → 5` | 多些内部动作 |
| **完全重置** | 脚本 `[2]` | 带时间戳备份，随时能回 |

### 会话历史另有一套

`state.db` 存所有会话、消息、工具调用，还有 FTS5 搜索索引。

```yaml
# 默认值（注释里，需要时取消）
sessions:
  auto_prune: true            # 自动删已结束的会话
  retention_days: 90          # 保留 90 天
  vacuum_after_prune: true    # 删完回收磁盘
  min_vacuum_interval_days: 30
  min_interval_hours: 24
```

**永不删除的三类**（原文）：

- `open`（进行中）
- `pinned`（已固定）
- `in-progress`（处理中）

僵尸会话（cron / kanban / subagent 进程死亡残留）**先被关闭，再过完整保留窗口**才删。

**VACUUM 触发条件是 AND，不是 OR**：

1. 距上次 VACUUM 超过 `min_vacuum_interval_days`（30 天）
2. 可回收页 **超过 25%**

原文解释了原因：密集数据库不值得为回收几 MB 做全量重写。

想永久保留：

```yaml
sessions:
  auto_prune: false
```

---

# 从零开始（六步）

> 没装过 Hermes 的从这里开始。已经装好的跳到 [第四步](#第四步用脚本改写人格)。

## 第一步：装 Hermes

### 1.1 下载安装

去 **https://nousresearch.com** 下载 Windows 版。

装完的目录：

```
C:\Users\<你>\AppData\Local\hermes\
├── bin\hermes.exe        ← 命令行
├── hermes-agent\         ← 本体
├── config.yaml           ← 配置
├── memories\             ← 角色卡和记忆 ★
└── desktop\              ← 桌面界面
```

### 1.2 验证

打开 PowerShell：

```powershell
& "$env:LOCALAPPDATA\hermes\bin\hermes.exe" --version
```

应该看到：

```
Hermes Agent v0.22.0+40.g6e84ce6 (2026.9.24) · stable
Install directory: C:\Users\<你>\AppData\Local\hermes\hermes-agent
Python: 3.14.7
```

**看到版本号就成功了。**

## 第二步：配一个模型

三选一：

### A. 云端 API（新手推荐）

以 DeepSeek 为例：

1. 去 **https://platform.deepseek.com** 拿 key（`sk-` 开头）
2. 写进 `.env`：

```powershell
notepad "$env:LOCALAPPDATA\hermes\.env"
```

```ini
DEEPSEEK_API_KEY=sk-你的密钥
```

3. 改 `config.yaml` 的 `model:` 段：

```yaml
model:
  default: "deepseek-chat"
  provider: "deepseek"
  base_url: "https://api.deepseek.com/v1"
```

4. 重启 Hermes

### B. 图形化向导

```powershell
& "$env:LOCALAPPDATA\hermes\bin\hermes.exe" setup model
```

### C. 本地模型

见 [第二部分](#第二部分本地模型有显卡再考虑)。新手先跳过。

## 第三步：说第一句话

重启后发一句：

```
你好，介绍一下你自己
```

能回复就说明链路通了。

## 第四步：用脚本改写人格

**这一步是本项目的核心。**

### 4.1 拿到脚本

**推荐：直接下 Lite 包**

[**Hermes-Persona-Card-Lite-v1.0.0.zip**](https://github.com/Alexander390370/Hermes-Persona-Card/releases/download/v1.0.0/Hermes-Persona-Card-Lite-v1.0.0.zip)（4.9 KB）

解压到任意目录，里面已经有脚本和三份模板。

**或者用 git：**

```powershell
git clone https://github.com/Alexander390370/Hermes-Persona-Card.git
```

**或者只要这一个文件：**

从仓库里单独下载 [`scripts/Hermes角色卡.bat`](scripts/Hermes角色卡.bat)。

### 4.2 双击运行

```
Hermes角色卡.bat
```

看到菜单，当前内容显示的是你现在的人格。

### 4.3 换一个

**方法一：套用模板（最快）**

按 `5`，然后把示例文件拖进窗口：

```
examples\persona-full.md
```

原内容自动备份成 `USER.md.bak-before-template`。

**方法二：自己写**

按 `1`，记事本打开，写：

```markdown
## 身份
你的名字是「阿鲸」。你是一个话不多但靠得住的技术助手。

## 说话方式
- 先结论，后理由
- 不用「好的，我来帮你」这类开场
- 中文回答；代码、命令、路径、报错原文保持原样
- 不确定就说不确定，不要编

## 边界
- 删除、发布、涉及金额的操作，先说明再执行
```

存盘关闭。

**方法三：清空重来**

按 `2`，先备份再清空，然后在空白文件里从零写。

### 4.4 生效

**开一个新会话**（旧会话的上下文已经定死），发一句话验证。

## 第五步：调记忆

想让角色卡更稳（不被 Agent 改）：

```yaml
memory:
  user_profile_enabled: false
```

想记得更多：

```yaml
memory:
  user_char_limit: 2750
  memory_char_limit: 4400
```

改完重启。

## 第六步：验证全链路

做个对照实验：

1. 用脚本 `[1]` 写一个明确的特征：「每句话结尾加 🐋」
2. 开新会话问「1+1 等于几」
3. 如果回复带 🐋 → **角色卡生效了**

再切到 `USER.md` 为空的会话，同样的问题 → 没有 🐋。

**这就是第 1 层压过其他所有设置的确凿证据。**

---

## 常见问题

**Q：改完没反应？**

两个原因：

1. **没开新会话** —— `USER.md` 只在会话开始时读一次
2. **`USER.md` 里有旧内容压着** —— 用脚本 `[3]` 看看，必要时 `[2]` 清空

**Q：脚本闪一下就没了？**

出错了。在 PowerShell 里跑能看到报错：

```powershell
.\Hermes角色卡.bat
```

**Q：能写多长？**

**1375 字符**（约 500 字）。脚本菜单会实时显示当前体积，超了会被截断。

**Q：改了会影响旧对话吗？**

不会。旧会话上下文已定死，只有新会话用新角色卡。

**Q：能不能不同会话用不同人格？**

可以。改 `USER.md` 后开新会话就是新人格。

**Q：Agent 自己改了 `USER.md` 怎么办？**

用脚本 `[3]` 看备份列表，`[4]` 选一个还原。
彻底根治就把 `user_profile_enabled` 设成 `false`。

**Q：`SOUL.md` 要不要一起改？**

不要。`SOUL.md` 管"怎么说"（语气底座），`USER.md` 管"是谁"。
**一起改容易互相干扰**，先只动 `USER.md`。

---

# 第二部分 · 本地模型（有显卡再考虑）

## 为什么推荐 4B

| 指标 | 值 |
|---|---|
| 量化体积 | **2.52 GB**（Q4_K_M） |
| 上下文 | **96K** |
| 视觉 | ✅ 支持 |
| 审查 | **无审查** |
| 生成速度 | **55~68 tok/s** |
| 显存占用 | 约 6.6 GB |

8GB 卡上能开 96K 上下文还留 1.3GB 余量，比 9B 快约 70%。

## 两个模型，按需选

8GB 卡**同时只能跑一个**：

| 模型 | 别名 | 端口 | 特点 |
|---|---|---:|---|
| Qwopus3.5-4B-Coder-MTP | `qwopus4b` | **8400** | 有审查，**支持工具调用** |
| Qwen3.5-4B-Heretic | `heretic4b` | **8420** | **无审查**，有视觉 |

## 接进 Hermes

```yaml
model:
  default: "heretic4b"
  provider: "custom"
  base_url: "http://127.0.0.1:8420/v1"
```

**三处必须对齐**：别名、端口、`provider: custom`。

完整启动脚本、参数详解、五个坑见 [`docs/local-model.md`](docs/local-model.md)。

---

# 第三部分 · 为什么 `USER.md` 优先级最高

## system prompt 的拼接顺序

```
[SOUL.md 语气底座]
[personality 预设内容]      ← 第 2 层
[USER.md 内容]              ← 第 1 层，在这
[工具定义 / 会话历史 / 用户消息]
```

两个原因让它成为最强：

1. **位置靠后** —— 后出现的内容对模型行为影响更直接
2. **语义是"事实"** —— `USER.md` 是"用户档案"，模型当作已知事实接受，
   而预设是"角色说明"，模型知道那是在扮演

## 所以有个很爽的玩法

```
本地 4B（免费、无审查）  ┐
Kimi                     ├──→  同一个 USER.md  ──→  同一个人格
DeepSeek                 │
GLM / Qwen / Claude      ┘
```

**换模型不换人格。** 显存不够就降小模型，能力退一步，人设一点不变。

## 自定义预设（备用方案）

如果只想快速切换而不想改 `USER.md`：

```yaml
# config.yaml → agent.personalities
agent:
  personalities:
    mentor: "You are a supportive mentor. Guide, don't lecture."
    reviewer:
      system_prompt: "You are a meticulous code reviewer."
      tone: "direct"
      style: "terse"
```

启用：

```yaml
display:
  personality: 'mentor'      # 空字符串 '' = 不启用
```

**注意**：这条路的优先级低于 `USER.md`。要用它，先清空 `USER.md`。

---

# 附录

## 角色卡怎么写

### 反面教材

```markdown
你是一个非常有帮助的助手，总是尽力提供最好最专业的回答……
```

全是形容词，没有可执行约束。1375 字符里塞这些是纯浪费。

### 正确做法：写可判断的约束

```markdown
- 先结论，后理由
- 不用「好的，我来帮你」这类开场
- 不确定就说不确定
```

每一条都能判断"是否违反"。

### 字符预算分配

| 部分 | 建议占比 |
|---|---:|
| 身份 | 15% |
| 说话方式 | 35% |
| 工作习惯 | 25% |
| 边界 | 20% |
| 其他 | 5% |

## Hermes 自带的 15 个人格

**仅供参考，本项目不推荐用它们做主入口**（原因见开头）。

```yaml
display:
  personality: 'kawaii'
```

```
helpful  concise  technical  creative  teacher
kawaii   catgirl  pirate     shakespeare  surfer
noir     uwu      philosopher  hype
```

定义在 `hermes_cli/personality.py`，所有界面可用。

## 23 个 provider

完整表见 [`docs/model-setup.md`](docs/model-setup.md)。最常用的：

| provider | 需要的凭据 |
|---|---|
| `deepseek` | `DEEPSEEK_API_KEY` |
| `anthropic` | `ANTHROPIC_API_KEY` |
| `openrouter` | `OPENROUTER_API_KEY` |
| `zai` | `GLM_API_KEY` |
| `kimi-coding` | `KIMI_API_KEY` |
| `gemini` | `GOOGLE_API_KEY` |
| **`custom`** | `base_url` — 任意 OpenAI 兼容端点 |

## 九个实测坑

完整版在 [`docs/troubleshooting.md`](docs/troubleshooting.md)：

1. 改了人格预设没反应 → `USER.md` 压着
2. `.bat` 中文全变乱码 → UTF-8 + LF 双重问题
3. 加了 `chcp 65001` 反而更乱 → 编码对着干
4. **`chcp` 切换后脚本卡住等输入** → 输入流解码失效
5. 改完 `USER.md` 当前会话没变化 → 会话开始时注入
6. **角色卡被自动内容塞满** → `user_profile_enabled`
7. `USER.md` 显示乱码 → UTF-8 内容 + cp936 终端
8. PowerShell 跑 bat 乱码但实际正常 → 抓取层问题
9. 脚本卡在 `set /p` → 自动化要给输入重定向

## 实测记录

| 项 | 值 |
|---|---|
| 平台 | Windows 11 |
| Hermes | v0.22.0+40.g6e84ce6（2026.9.24） |
| 安装方式 | git（`AppData\Local\hermes\hermes-agent`） |
| Python | 3.14.7 |
| `user_char_limit` | 1375（约 500 token） |
| `memory_char_limit` | 2200（约 800 token） |
| `nudge_interval` | 10 轮 |
| 会话保留 | 90 天自动剪枝 |
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
│   └── Hermes角色卡.bat        # ★ 主脚本（GBK + CRLF）
├── examples/
│   ├── persona-minimal.md      # 一行版本
│   ├── persona-full.md         # 完整结构
│   └── persona-coder.md        # 程序员向
└── docs/
    ├── personality-system.md   # 三层人格 + 记忆调优详解
    ├── local-model.md          # 本地 4B 部署
    ├── hermes-filemap.md       # 目录全图
    ├── model-setup.md          # 23 个 provider
    └── troubleshooting.md      # 九个坑复盘
```

## 许可

本项目代码 MIT。

Hermes Agent 由 [Nous Research](https://nousresearch.com) 构建。
本仓库只在其配置层做工具封装，**不包含、不重分发** Hermes 本体。
