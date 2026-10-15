# ============================================================
#  一键把本文件夹发布到 GitHub Pages
#  用法：双击 deploy.bat，或在本目录执行
#        powershell -NoProfile -ExecutionPolicy Bypass -File .\deploy.ps1
# ============================================================
$ErrorActionPreference = 'Stop'
$owner  = 'xiaopeng-jpg'
$repo   = 'xiaopeng-jpg.github.io'
$remote = "https://github.com/$owner/$repo.git"

function Info($m){ Write-Host $m -ForegroundColor Cyan }
function Ok($m){ Write-Host $m -ForegroundColor Green }
function Warn($m){ Write-Host $m -ForegroundColor Yellow }

Set-Location -LiteralPath $PSScriptRoot

if(-not (Get-Command git -ErrorAction SilentlyContinue)){
  Warn '没有找到 git。'
  Write-Host '先安装 Git： https://git-scm.com/download/win'
  Write-Host '或改用 README.md 里的「网页上传」方式（不需要装软件）。'
  exit 1
}
Info ("git 版本: " + (git --version))

if(-not (Test-Path -LiteralPath '.git')){ git init | Out-Null; Info '已初始化本地仓库' }
if(-not (git config user.email)){ git config user.email 'xiaopeng-jpg@users.noreply.github.com' }
if(-not (git config user.name)){  git config user.name  'xiaopeng' }

git add -A
$staged = git diff --cached --name-only
if(-not $staged){ Warn '没有需要提交的改动。' } else {
  $hasCommit = $true
  try { git rev-parse --verify HEAD | Out-Null } catch { $hasCommit = $false }
  if($hasCommit){ git commit -m "更新婚纱照网站" | Out-Null } else { git commit -m "初始化婚纱照网站" | Out-Null }
  Ok ('已提交 ' + ($staged | Measure-Object).Count + ' 个文件')
}

$cur = git rev-parse --abbrev-ref HEAD
if($cur -ne 'main'){ git branch -M main; Ok '分支已改为 main' }

$remotes = @(git remote)
if($remotes -notcontains 'origin'){ git remote add origin $remote } else { git remote set-url origin $remote }
Info "远程仓库: $remote"

Info '正在推送...'
try {
  git push -u origin main
  Ok '推送成功'
} catch {
  Warn '推送失败。常见原因：'
  Write-Host '  1) 仓库还不存在 → 先去 https://github.com/new 建一个名为 xiaopeng-jpg.github.io 的 Public 仓库'
  Write-Host '     或执行： gh repo create xiaopeng-jpg/xiaopeng-jpg.github.io --public --source=. --push'
  Write-Host '  2) 没登录 → 执行 gh auth login，或让 Git Credential Manager 弹窗登录'
  Write-Host '  3) 网页上建过仓库且带 README → 先执行： git pull --rebase origin main'
  exit 1
}

if(Get-Command gh -ErrorAction SilentlyContinue){
  try {
    gh api -X POST "repos/$owner/$repo/pages" -f 'source[branch]=main' -f 'source[path]=/' | Out-Null
    Ok 'GitHub Pages 已开启（main / root）'
  } catch {
    try {
      gh api -X PUT "repos/$owner/$repo/pages" -f 'source[branch]=main' -f 'source[path]=/' | Out-Null
      Ok 'GitHub Pages 已开启（main / root）'
    } catch {
      Warn '自动开启 Pages 失败，请手动：Settings → Pages → Source: main / (root) → Save'
    }
  }
} else {
  Warn '没装 GitHub CLI，无法自动开启 Pages。手动：仓库 Settings → Pages → Deploy from a branch → main / (root)'
}

Write-Host ''
Ok "完成！1~2 分钟后访问： https://$owner.github.io/"
