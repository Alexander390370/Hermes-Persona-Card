# 排错手册

> 全部为本项目实测踩到的真实问题，不是理论清单。

---

## 1. 改了人格预设没反应

**症状**

把 `config.yaml` 的 `display.personality` 从 `kawaii` 改回默认，重启 Hermes，
人格**依然是 Kawai**。

**误判过程**

一开始怀疑：配置文件没保存 / 数据库缓存 / 进程没重启 / dump 里的残留。
全都排查过，都是干净的。

**根因**

`memories/USER.md` 里有这两句：

```markdown
User prefers kawaii mode
```

它优先级**高于**任何界面预设。预设改了，`USER.md` 还压着，所以不变。

**修法**

```batch
scripts\Hermes角色卡.bat
```

选 `1` 编辑，删掉那两句。或者选 `2` 清空重写。

**教训**：`USER.md` 不是"记忆"，是"角色卡"，优先级最高。

---

## 2. `.bat` 中文全变乱码

**症状**

```
'tepad' 不是内部或外部命令
'ear-!STAMP!"' 不是内部或外部命令
Missing closing '}'
```

**两个原因**（经常同时出现）

**(a) 文件是 UTF-8，cmd 按 GBK 解码**

UTF-8 的中文字节被当 GBK 读 → 乱码 → 字节错位 → 括号被吞。
`notepad` 的 `n` 被吃掉，就变成 `'tepad'`。

**(b) 文件是 LF 换行**

`.bat` 必须 CRLF。LF 会让 `set` 和后面拼在一起，产生 `'ear-!STAMP!"'` 这种错。

**修法**

```powershell
$text = Get-Content '源.bat' -Raw -Encoding UTF8
$text = $text.Replace("`r`n","`n").Replace("`n","`r`n")   # 规范成 CRLF
[System.IO.File]::WriteAllBytes('目标.bat',
    [System.Text.Encoding]::GetEncoding(936).GetBytes($text))
```

**验证**

```powershell
$b = [System.IO.File]::ReadAllBytes('目标.bat')
$b[0] -eq 0xEF                        # False = 无 BOM
[Text.Encoding]::GetEncoding(936).GetString($b).Contains("`r`n")  # True
```

---

## 3. 加了 `chcp 65001` 反而更乱

**症状**

文件本身是 GBK，又加了 `chcp 65001`，中文变成双重乱码。

**原因**

`chcp 65001` 是给 **UTF-8 文件**用的。GBK 文件 + UTF-8 代码页 = 对着干。

**规则**

| 文件编码 | 是否加 `chcp 65001` |
|---|---|
| GBK (cp936) | ❌ **不加** |
| UTF-8 | ✅ 加 |

**二选一，不要混。**

---

## 4. 用 `chcp` 切换后脚本卡住等输入

**症状**

在脚本里临时 `chcp 65001` 显示一段内容，切回 `chcp 936` 后，
后面的 `set /p` **收不到输入了**。

**原因**

`chcp` 切换会影响标准输入流的解码方式，管道输入会失效。

**修法**

不要用 `chcp` 切换。改用 PowerShell 转码输出：

```batch
powershell -NoProfile -Command "$c=Get-Content -LiteralPath '%TARGET%' -Raw -Encoding UTF8; [Console]::OutputEncoding=[Text.Encoding]::GetEncoding(936); Write-Output $c" 2>nul
if errorlevel 1 type "%TARGET%" 2>nul
```

`USER.md` 是 UTF-8，脚本本身是 GBK。这样能把 UTF-8 内容按 GBK 正确显示，
且不动输入流。

---

## 5. 改完 `USER.md` 当前会话没变化

**症状**

编辑器里明明改了，对话里人格还是旧的。

**原因**

`USER.md` 在**会话开始时**注入。已存在的会话上下文已经定死。

**修法**

开新会话。旧的关掉或 `/new`。

---

## 6. 角色卡被自动内容塞满

**症状**

过一段时间，`USER.md` 里出现一堆自己没写过的句子，
可能是 `- User prefers ...` 这种。

**原因**

```yaml
memory:
  user_profile_enabled: true
```

开着这个，Agent 会往 `USER.md` 追加"学到的用户偏好"。

**修法**

- **不想让它写**：`user_profile_enabled: false`
- **想留着但防意外**：定期跑脚本做备份，发现被改就还原
- **看一眼上限**：`user_char_limit: 1375`，超了会截断

---

## 7. `USER.md` 显示乱码（脚本里）

**症状**

脚本里 `type "%TARGET%"` 显示出来的中文是乱码，
但记事本打开是正常的。

**原因**

`USER.md` 是 **UTF-8**，脚本运行的 cmd 是 **cp936**。编码不匹配。

**修法**

见第 4 条，用 PowerShell 转码输出。

---

## 8. PowerShell 里跑 bat 中文乱码但实际正常

**症状**

在 PowerShell 里执行 bat，抓到的输出中文乱码；
但双击运行、或在 cmd 窗口里跑，显示正常。

**原因**

PowerShell 的控制台输出编码可能是 65001，而 bat 输出的是 GBK 字节。
这是**抓取层**的问题，不是脚本问题。

**验证**

跑一次，把输出重定向到文件，再用 GBK 读：

```powershell
cmd /d /c "脚本.bat < nul > out.txt 2>&1"
[Text.Encoding]::GetEncoding(936).GetString(
    [IO.File]::ReadAllBytes('out.txt'))
```

如果这样读出来是正常的，脚本就没问题。

---

## 9. 脚本卡在 `set /p` 等输入（自动化场景）

**症状**

用脚本自动化跑 bat，进程挂住不退出。

**原因**

`set /p` 在等输入。如果脚本里有 `start "" notepad` 这类交互调用，
更会一直挂着。

**修法**

给输入重定向：

```powershell
# 前提：脚本的退出选项是 q
[IO.File]::WriteAllText("$env:TEMP\q.txt", "q`r`n")
cmd /d /c "脚本.bat < %TEMP%\q.txt > out.txt 2>&1"
```

**注意**：如果脚本内部有 `chcp` 切换，重定向会失效（见第 4 条）。

---

## 快速自检清单

改完 `.bat` 后逐项确认：

- [ ] 首字节不是 `0xEF`（无 BOM）
- [ ] 以 GBK (cp936) 编码保存
- [ ] 换行是 CRLF
- [ ] 没有同时出现 `chcp 65001` 和 GBK 内容
- [ ] 双击运行，菜单中文正常
- [ ] 每个菜单项都能走到，不报 `'xxx' 不是内部或外部命令`
- [ ] 涉及 `set /p` 的地方能正常收到输入
