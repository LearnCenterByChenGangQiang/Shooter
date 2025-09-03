#!/bin/bash

# 检查参数并分离提交信息和推送标志
push_flag=0
commit_msg=""

if [ $# -gt 0 ] && [ "$1" = "-p" ]; then
    push_flag=1
    shift  # 移除-p参数，处理剩余参数作为提交信息
fi

# 检查是否提供了提交信息
if [ -z "$1" ]; then
  echo "❌ 错误：请在命令后添加提交信息"
  echo "✅ 示例用法："
  echo "  仅本地提交：./git_auto_commit.sh \"修复了布局问题\""
  echo "  提交并推送：./git_auto_commit.sh -p \"修复了布局问题\""
  exit 1
fi

commit_msg="$1"

# 检查提交信息是否为空（仅包含空白字符）
if [ -z "$(echo "$commit_msg" | xargs)" ]; then
  echo "❌ 错误：提交信息不能为空或仅包含空白字符"
  exit 1
fi

# 检查是否已有相同提交信息
if git log --pretty=format:"%s" | grep -Fxq "$commit_msg"; then
  echo "⚠️ 提交信息 \"$commit_msg\" 已经存在于历史记录中。"
  read -p "是否仍然继续提交？[y/N]: " confirm
  confirm=${confirm:-n}

  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "🚫 取消提交。"
    exit 0
  fi
fi

# 执行 Git 操作
git add .
git commit -m "$commit_msg"

# 如果指定了-p参数，则执行推送
if [ $push_flag -eq 1 ]; then
    git push
    echo "🚀 已提交并推送到远程仓库"
else
    echo "✅ 已完成本地提交，未推送至远程仓库"
    echo "ℹ️ 提示：使用 -p 参数可同时推送，例如：./git_auto_commit.sh -p \"提交信息\""
fi
