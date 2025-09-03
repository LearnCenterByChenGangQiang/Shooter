@echo off
setlocal enabledelayedexpansion
title Git Commit/Push with Message (循环模式)

:: 检查是否在Git仓库中
:check_repo
echo [检查] 验证当前目录是否为Git仓库...
git rev-parse --is-inside-work-tree >nul 2>&1 || (
    echo [错误] 当前目录不是一个 Git 仓库
    pause
    exit /b 1
)
echo [检查] 已确认是Git仓库

:: 检查是否需要执行push
set "perform_push=0"
if "%1"=="-p" set "perform_push=1"
if "%1"=="--push" set "perform_push=1"

:: 显示操作模式
if %perform_push% equ 1 (
    echo [模式] 将执行 Commit 并 Push 操作
) else (
    echo [模式] 将仅执行 Commit 操作（如需Push，请添加 -p 或 --push 参数）
)

:start_commit
:: 输入 commit message，增加空检查
echo.
set "msg="
set /p msg=请输入 commit message（不能为空）: 

:: 检查输入是否为空
if "!msg!"=="" (
    echo [错误] commit message 不能为空，请重新输入！
    goto start_commit
)

echo [信息] 使用的Commit信息：%msg%

echo.
echo ===== 开始执行操作 =====

:: 执行添加操作
echo [步骤1/3] 正在将所有更改添加到暂存区...
git add -A
if %errorlevel% equ 0 (
    echo [步骤1/3] 更改已成功添加到暂存区
) else (
    echo [错误] 添加更改时出现问题
    goto end_operation
)

:: 执行提交操作
echo.
echo [步骤2/3] 正在执行Commit操作...
git commit -m "%msg%"
if %errorlevel% equ 0 (
    echo [步骤2/3] Commit操作已完成
) else (
    echo [错误] Commit操作失败
    goto end_operation
)

:: 只有指定了参数时才执行push
if %perform_push% equ 1 (
    echo.
    echo [步骤3/3] 正在执行Push操作...
    git push
    if %errorlevel% equ 0 (
        echo [步骤3/3] Push操作已完成
    ) else (
        echo [错误] Push操作失败
        goto end_operation
    )
)

:end_operation
echo.
echo ===== 操作完成 =====
if %perform_push% equ 1 (
    echo 已成功执行：Commit 并 Push
) else (
    echo 已成功执行：Commit（未执行 Push）
    echo 提示：下次运行时添加 -p 或 --push 参数可同时执行推送
)

:: 等待用户按键后重新开始
echo.
echo 按任意键开始新的提交...
pause >nul
cls
goto start_commit
