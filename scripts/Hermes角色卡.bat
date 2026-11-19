@echo off
title Hermes 角色卡
setlocal enabledelayedexpansion

set "HERMES=%LOCALAPPDATA%\hermes"
set "TARGET=%HERMES%\memories\USER.md"
set "BAKDIR=%HERMES%\memories"
set "SOUL=%HERMES%\SOUL.md"
set "CFG=%HERMES%\config.yaml"

:MENU
cls
echo.
echo ============================================================
echo    Hermes 角色卡（USER.md）
echo ============================================================
echo.
if not exist "%HERMES%" (
    echo   [找不到 Hermes 目录]
    echo   %HERMES%
    echo.
    echo   先安装并运行一次 Hermes，再回来。
    echo.
    pause
    goto END
)
echo  文件: %TARGET%
echo.
echo  这就是一张角色卡。写什么，它就是什么。
echo  每次请求都会读它，优先级高于界面里的人格预设。
echo.
REM ---- 显示字数占用 ----
if exist "%TARGET%" (
    for %%A in ("%TARGET%") do set "FSIZE=%%~zA"
    echo  当前体积: !FSIZE! 字节 ^| 建议上限: 1375 字符
)
echo.
echo ------------------------------------------------------------
echo  当前内容:
echo ------------------------------------------------------------
if exist "%TARGET%" (
    powershell -NoProfile -Command "$c=Get-Content -LiteralPath '%TARGET%' -Raw -Encoding UTF8; [Console]::OutputEncoding=[Text.Encoding]::GetEncoding(936); Write-Output $c" 2>nul
    if errorlevel 1 type "%TARGET%" 2>nul
) else (
    echo   [文件不存在]
)
echo.
echo ------------------------------------------------------------
echo  相关文件:
if exist "%SOUL%" echo    SOUL.md    存在（说话风格底座，一般不动）
if exist "%CFG%"  echo    config.yaml 存在（模型与显示设置）
echo ------------------------------------------------------------
echo.
echo   [1] 编辑（记事本，写完存盘即可）
echo   [2] 清空重写
echo   [3] 查看历史备份
echo   [4] 恢复备份
echo   [5] 从示例快速套用
echo   [6] 打开 Hermes 配置目录
echo   [q] 退出
echo.
set "C="
set /p "C=请选择: "

if /i "!C!"=="q" goto END
if "!C!"=="1" goto EDIT
if "!C!"=="2" goto CLEAR
if "!C!"=="3" goto BACKUP_LIST
if "!C!"=="4" goto RESTORE
if "!C!"=="5" goto TEMPLATE
if "!C!"=="6" goto OPENDIR
goto MENU

:EDIT
if not exist "%BAKDIR%" mkdir "%BAKDIR%" >nul 2>&1
if exist "%TARGET%" (
    copy /y "%TARGET%" "%BAKDIR%\USER.md.bak-before-edit" >nul 2>&1
    echo  已备份到 USER.md.bak-before-edit
)
if not exist "%TARGET%" (
    type nul > "%TARGET%"
    echo  已创建空 USER.md
)
start "" notepad "%TARGET%"
echo.
echo  已打开记事本。存盘后关闭，改动即生效。
echo  （需要新建会话才会读取新内容）
echo.
pause
goto MENU

:CLEAR
if not exist "%BAKDIR%" mkdir "%BAKDIR%" >nul 2>&1
if exist "%TARGET%" (
    call :STAMP
    copy /y "%TARGET%" "%BAKDIR%\USER.md.bak-before-clear-!STAMP!" >nul 2>&1
    echo  已备份旧内容到 USER.md.bak-before-clear-!STAMP!
)
type nul > "%TARGET%"
start "" notepad "%TARGET%"
echo.
echo  已清空并打开记事本。写入你想要的内容后存盘。
echo.
pause
goto MENU

:BACKUP_LIST
cls
echo.
echo ============================================================
echo   历史备份
echo ============================================================
echo.
if exist "%BAKDIR%\USER.md.bak*" (
    dir /b /o-d "%BAKDIR%\USER.md.bak*" 2>nul
) else (
    echo   （没有备份）
)
echo.
pause
goto MENU

:RESTORE
cls
echo.
echo ============================================================
echo   恢复备份
echo ============================================================
echo.
if exist "%BAKDIR%\USER.md.bak*" (
    dir /b /o-d "%BAKDIR%\USER.md.bak*" 2>nul
) else (
    echo   （没有备份可恢复）
    echo.
    pause
    goto MENU
)
echo.
set "B="
set /p "B=输入备份文件名（直接回车取消）: "
if "!B!"=="" goto MENU
if exist "%BAKDIR%\!B!" (
    if exist "%TARGET%" (
        copy /y "%TARGET%" "%BAKDIR%\USER.md.bak-before-restore" >nul 2>&1
    )
    copy /y "%BAKDIR%\!B!" "%TARGET%" >nul
    echo.
    echo  已恢复: !B!
    echo  原内容已存为 USER.md.bak-before-restore
) else (
    echo.
    echo  找不到: !B!
)
echo.
pause
goto MENU

:TEMPLATE
cls
echo.
echo ============================================================
echo   从示例快速套用
echo ============================================================
echo.
echo   输入示例文件路径（把 .md 文件拖进这个窗口即可）
echo   直接回车取消
echo.
set "T="
set /p "T=示例文件: "
if "!T!"=="" goto MENU
REM 去掉拖拽带上的引号
set "T=!T:"=!"
if not exist "!T!" (
    echo.
    echo  找不到文件: !T!
    echo.
    pause
    goto MENU
)
if exist "%TARGET%" (
    copy /y "%TARGET%" "%BAKDIR%\USER.md.bak-before-template" >nul 2>&1
)
copy /y "!T!" "%TARGET%" >nul
echo.
echo  已套用: !T!
echo  原内容已存为 USER.md.bak-before-template
echo  （需要新建会话才生效）
echo.
pause
goto MENU

:OPENDIR
start "" explorer "%HERMES%"
goto MENU

:STAMP
set "D=%DATE%"
set "T=%TIME%"
set "D=!D:/=!"
set "D=!D:-=!"
set "D=!D: =!"
set "T=!T::=!"
set "T=!T:.=!"
set "T=!T: =0!"
set "STAMP=!D!-!T:~0,6!"
goto :eof

:END
endlocal
exit /b 0
