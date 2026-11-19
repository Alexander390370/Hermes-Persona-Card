# Hermes 目录全图

> 实测于 Windows 11 + Hermes Desktop（`_config_version: 50`）。
> 路径根：`%LOCALAPPDATA%\hermes\`

## 顶层文件

| 文件 | 体积（实测） | 作用 | 该动吗 |
|---|---:|---|---|
| `config.yaml` | 126.9 KB | 全部配置：模型、显示、记忆、插件、网关 | ✅ 模型/显示可改 |
| `.env` | 28 B | API 密钥（`DEEPSEEK_API_KEY` 等） | ✅ 填自己的 key |
| `auth.json` | 7.4 KB | OAuth 凭据（Nous Portal 等） | ⚠️ 由 `hermes auth` 管 |
| `SOUL.md` | 0.7 KB | 说话风格底座 | ⚠️ 一般不动 |
| `.skills_prompt_snapshot.json` | 44.1 KB | 技能提示词快照 | ❌ 自动生成 |
| `models_dev_cache.json` | 6576 KB | 模型目录缓存 | ❌ 自动生成 |
| `provider_models_cache.json` | 1.6 KB | provider 模型列表缓存 | ❌ 自动生成 |
| `state.db` | 2868 KB | 主状态库（SQLite） | ❌ 别碰 |
| `state.db-wal` | 2498.6 KB | WAL 日志 | ❌ 别碰 |
| `shared-state.db` | 152 KB | 共享状态 | ❌ 别碰 |
| `projects.db` | 44 KB | 项目索引 | ❌ 别碰 |
| `spawn-ledger.json` | 0.5 KB | 子进程台账 | ❌ 自动生成 |
| `install_id` | 0 B | 安装标识 | ❌ 别碰 |
| `hermes-setup.exe` | 7759.8 KB | 安装器 | ❌ 别碰 |

## `memories/` 目录

| 文件 | 体积（实测） | 作用 |
|---|---:|---|
| **`USER.md`** | 0.06 KB | **角色卡（本项目主角）** |
| `MEMORY.md` | — | Agent 自己的笔记 |
| `USER.md.bak-*` | 0.37~0.53 KB | 历史备份 |

上限（`config.yaml` → `memory`）：

```yaml
memory_char_limit: 2200      # MEMORY.md，约 800 token
user_char_limit: 1375        # USER.md，约 500 token
nudge_interval: 10           # 每 10 轮提醒写记忆
```

## 子目录一览

| 目录 | 作用 | 关注度 |
|---|---|---|
| `memories/` | **角色卡与记忆** | 🔴 高 |
| `skills/` | 技能定义 | 🟡 中 |
| `plugins/` | 插件 | 🟡 中 |
| `desktop-plugins/` | 桌面端插件 | 🟡 中 |
| `sessions/` | 会话记录 | 🟢 低 |
| `logs/` | 运行日志 | 🟢 排错时看 |
| `backups/` | 配置备份（含 `.yaml` 快照） | 🟢 低 |
| `cache/` | 各类缓存（含 uv 包缓存） | 🟢 低 |
| `cron/` | 定时任务 | 🟡 中 |
| `hooks/` | 钩子 | 🟡 中 |
| `tools/` | 工具定义 | 🟢 低 |
| `vault/` | 凭据保险库 | 🔴 高（别手动改） |
| `sandboxes/` | 沙箱环境 | 🟢 低 |
| `runtime/` | 运行时 | 🟢 低 |
| `state/` | 状态数据 | 🟢 低 |
| `telemetry/` | 遥测 | 🟢 低 |
| `image_cache/` `audio_cache/` | 媒体缓存 | 🟢 可清 |
| `pairing/` `bot_relay/` | 配对与中转 | 🟢 低 |
| `free_tier/` `rate_limits/` | 配额 | 🟢 低 |
| `locks/` | 锁文件 | 🟢 低 |
| `installs/` `bootstrap-cache/` | 安装缓存 | 🟢 可清 |
| `source-checks/` | 源码校验 | 🟢 低 |

## `config.yaml` 顶层键（实测顺序）

```yaml
_config_version: 50
database:
runtime:
attachments:
plugins:
model:              # ← 模型配置
kanban:
cron:
terminal:
browser:
tool_loop_guardrails:
compression:
prompt_caching:
memory:             # ← 记忆与角色卡上限
max_concurrent_sessions:
group_sessions_per_user: true
streaming:
skills:
agent:
gateway:
platform_toolsets:
stt:
code_execution:
delegation:
display:            # ← 界面显示与人格预设
telemetry:
auth:
updates:
onboarding:
providers:          # ← provider 定义
```

## 关键段示例

### model

```yaml
model:
  default: "deepseek-flash"
  provider: "deepseek"
  base_url: "https://api.deepseek.com/v1"
```

### display

```yaml
display:
  compact: false        # true = 单行横幅，false = 完整 ASCII 横幅
```

`tool_progress` 可选值（原文）：

| 值 | 行为 |
|---|---|
| `off` | 静默，只显示最终回复 |
| `new` | 仅在工具变化时显示指示器 |
| `all` | 显示每次工具调用（默认） |
| `verbose` | 完整参数、结果、调试日志 |
| `log` | 聊天静默，写入 `~/.hermes/logs/tool_calls.log` |

### memory

```yaml
memory:
  memory_enabled: true
  user_profile_enabled: true
  prefetch_spill_enabled: false
  memory_char_limit: 2200
  user_char_limit: 1375
  nudge_interval: 10
```
