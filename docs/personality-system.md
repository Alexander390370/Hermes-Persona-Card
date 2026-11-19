# 人格系统详解

> 全部内容来自本机 `config.yaml` 的实际注释与配置。

---

## 三层结构

Hermes 的人格由三层叠加而成，**优先级从高到低**：

| 层 | 位置 | 生效方式 | 上限 |
|---|---|---|---:|
| **1 最高** | `memories/USER.md` | 每次请求注入 system prompt | 1375 字符 |
| 2 | `display.personality` → 预设定义 | 按名字查表 | — |
| 3 最低 | 模型训练倾向 | 天生 | — |

### 为什么第 1 层最强

`USER.md` 是**每次请求都拼进 system prompt 的文本**，位置在预设之后。
模型读到的顺序是：

```
[SOUL.md 语气底座]
[personality 预设内容]      ← 第 2 层
[USER.md 内容]              ← 第 1 层，在这
[工具定义 / 会话历史 / 用户消息]
```

后出现的内容对模型行为影响更直接，而且 `USER.md` 用的是"用户档案"的语义
（"这个用户是谁、喜欢什么"），模型会当作事实接受。

**结论：要覆盖一个人格，必须改 `USER.md`；只改预设没用。**

---

## 第 1 层：USER.md

### 位置与上限

```
%LOCALAPPDATA%\hermes\memories\USER.md
```

```yaml
memory:
  user_char_limit: 1375     # 约 500 token
```

### 谁写它

**两个来源：**

1. **你自己写**（通过脚本或记事本）
2. **Agent 自己写**（`user_profile_enabled: true` 时）

第 2 点是坑：Agent 会往里追加"学到的用户偏好"，跑久了会挤占你的角色卡。

### 它和 MEMORY.md 的区别

| | `USER.md` | `MEMORY.md` |
|---|---|---|
| 语义 | 用户是谁 | Agent 自己的笔记 |
| 内容 | 偏好、风格、期望 | 环境事实、约定、学到的东西 |
| 默认上限 | 1375 字符 | 2200 字符 |
| 开关 | `user_profile_enabled` | `memory_enabled` |

两者**都注入 system prompt**，但 `USER.md` 的语义优先级更高。

### 写法：约束 vs 形容词

**无效写法：**

```markdown
你是一个专业、严谨、高效的助手，总是提供高质量的回答。
```

模型无法判断"专业"的具体标准，等于没写。

**有效写法：**

```markdown
- 先结论，后理由
- 不用「好的，我来帮你」这类开场
- 不确定就说不确定
```

每一条都能判断"是否违反"。这才是有效的行为约束。

### 字符预算怎么分配

1375 字符很紧。经验分配：

| 部分 | 建议占比 | 示例 |
|---|---:|---|
| 身份 | 15% | 名字、角色定位 |
| 说话方式 | 35% | 句子结构、语言、语气 |
| 工作习惯 | 25% | 动手前的检查、验证要求 |
| 边界 | 20% | 什么不能做、什么要先问 |
| 其他 | 5% | 记忆引用规则等 |

---

## 第 2 层：personality 预设

### 15 个内置

原文照抄自 `config.yaml` 注释：

```
helpful, concise, technical, creative, teacher, kawaii, catgirl,
pirate, shakespeare, surfer, noir, uwu, philosopher, hype
```

定义在 `hermes_cli/personality.py`，**所有界面都可用**。

### 切换方式

**配置文件：**

```yaml
display:
  personality: 'kawaii'    # 空字符串 '' = 不启用
```

**命令行：**

```
/personality kawaii
```

### 自定义人格

配置位置：`config.yaml` → `agent.personalities`

**两种写法：**

```yaml
agent:
  personalities:
    # 写法一：简写，值就是 system prompt
    mentor: "You are a supportive mentor. Guide, don't lecture."

    # 写法二：完整，可带 tone / style
    reviewer:
      system_prompt: "You are a meticulous code reviewer."
      tone: "direct"
      style: "terse"
```

**三条规则**（原文）：

1. 这里写的是**新增**，或**按名字覆盖**某个内置人格
2. 当前选中的存在 `display.personality`，**不在这里**
3. 也**不在** `agent.system_prompt`——那个字段是手写 system prompt 的地方

### 常见误解

**误解一：「改了预设就该生效」**

只要 `USER.md` 非空且有内容，预设就会被压制。
先清 `USER.md` 再切预设。

**误解二：「`agent.system_prompt` 能代替预设」**

`agent.system_prompt` 是**完全手动**的 system prompt，和预设机制是两条路。
两者都设时行为不叠加，容易互相干扰。**建议只用一种。**

---

## 第 3 层：模型

最底层，前两层空着时显露。通常不需要管。

**但有个实际价值**：因为前两层（尤其 `USER.md`）是**模型无关**的，
所以同一份 `USER.md` 在不同模型上表现一致。

这意味着：

```
本地 4B ─┐
本地 9B ─┤
Kimi   ─┼──→  同一份 USER.md  ──→  同一个人格，不同能力
DeepSeek┤
GLM    ─┘
```

**换模型不换人格**。显存不够就降小模型，能力退一步，人设不变。

---

## 记忆系统

### 配置全貌

```yaml
memory:
  memory_enabled: true          # MEMORY.md 总开关
  user_profile_enabled: true    # USER.md 自动写入开关
  prefetch_spill_enabled: false # 外部预取
  memory_char_limit: 2200       # MEMORY.md 上限
  user_char_limit: 1375         # USER.md 上限
  nudge_interval: 10            # 每 N 轮提醒写记忆
```

### 上限怎么换算

原文注释给了换算比例：**约 2.75 字符 = 1 token**（模型无关）。

| 配置值 | 约等于 |
|---|---|
| `user_char_limit: 1375` | 500 token |
| `memory_char_limit: 2200` | 800 token |
| 两者合计 | 1300 token |

**这 1300 token 是每一轮对话的固定开销。**

### 调优方案

#### 方案 A：记得更多

```yaml
memory:
  memory_char_limit: 4400
  user_char_limit: 2750
```

代价：固定开销从 1300 token 涨到约 2600 token。

#### 方案 B：人格更稳定

```yaml
memory:
  user_profile_enabled: false
```

关掉后 `USER.md` 只由你写，不会被 Agent 改动。
代价：它不会自己记住新偏好。

#### 方案 C：更主动记忆

```yaml
memory:
  nudge_interval: 5     # 默认 10
```

调小会让 Agent 更频繁考虑"值得记吗"。设 `0` 完全关掉提醒。

#### 方案 D：完全重置

```batch
scripts\Hermes角色卡.bat
# [2] 清空重写
```

会带时间戳备份。

---

## 会话历史的保留

`state.db` 存所有会话、消息、工具调用，还有 FTS5 搜索索引。

### 默认剪枝策略

| 项 | 默认值 | 说明 |
|---|---|---|
| `auto_prune` | `true` | 自动删已结束的会话 |
| `retention_days` | `90` | 保留 90 天 |
| `vacuum_after_prune` | `true` | 删完回收磁盘 |
| `min_vacuum_interval_days` | `30` | VACUUM 最小间隔 |
| `min_interval_hours` | `24` | 剪枝最小间隔 |

### 永不删除的

原文明确：

- `open`（进行中）
- `pinned`（已固定）
- `in-progress`（处理中）

**这三类永远不删。**

### 异常会话的处理

进程死亡导致的僵尸自动化会话（cron / kanban / subagent / one-shot CLI）：

1. 先被**关闭**
2. 再过**一个完整保留窗口**
3. 才允许删除

不会立刻删掉，留了一个缓冲期。

### VACUUM 的触发条件

**两个条件必须同时满足**：

1. 距离上次 VACUUM 超过 `min_vacuum_interval_days`（默认 30 天）
2. 可回收页超过文件的 **25%**

原文解释了为什么：密集的数据库不值得为回收几 MB 做一次全量重写。

### 永久保留

```yaml
sessions:
  auto_prune: false
```

这是 #54189 之前的行为。

---

## 快速对照表

| 我想…… | 改哪里 |
|---|---|
| 换一个人格 | `USER.md`（或脚本 `[5]` 套用示例） |
| 快速切预设 | `/personality <名字>` |
| 加自己的预设 | `agent.personalities` |
| 让预设生效 | 先清空 `USER.md` |
| 记得更多 | 调大 `*_char_limit` |
| 人格别被改 | `user_profile_enabled: false` |
| 完全重置 | 脚本 `[2]` |
| 保留所有会话 | `sessions.auto_prune: false` |
| 换模型不换人格 | 只改 `model`，不动 `USER.md` |
