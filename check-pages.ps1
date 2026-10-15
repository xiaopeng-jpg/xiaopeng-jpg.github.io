# ============================================================
#  GitHub Pages 一键诊断（不需要 git，不需要登录）
#  用法：在本文件夹空白处右键 → 在终端中打开 →
#        powershell -ExecutionPolicy Bypass -File .\check-pages.ps1
#  把输出整段复制发给 Codex 即可
# ============================================================
$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 若检测到沙箱黑洞代理(127.0.0.1:9)，清掉它，否则请求必然失败
foreach($n in 'HTTP_PROXY','HTTPS_PROXY','ALL_PROXY','GIT_HTTP_PROXY','GIT_HTTPS_PROXY'){
  $v = [Environment]::GetEnvironmentVariable($n)
  if($v -and $v -match '127\.0\.0\.1:9'){ Remove-Item "Env:$n" -ErrorAction SilentlyContinue; Write-Host "已清除无效代理 $n" -ForegroundColor DarkGray }
}

$owner = 'xiaopeng-jpg'
$repo  = 'xiaopeng-jpg.github.io'
$ua    = @{ 'User-Agent' = 'pages-check' }

function Get-Url([string]$url){
  try{
    $r = Invoke-WebRequest -Uri $url -TimeoutSec 25 -UseBasicParsing -Headers $ua
    return [pscustomobject]@{ code = $r.StatusCode; body = $r.Content }
  } catch {
    $resp = $_.Exception.Response
    if($resp){
      $code = 0; try { $code = [int]$resp.StatusCode } catch {}
      $body = ''
      try { $sr = New-Object System.IO.StreamReader($resp.GetResponseStream()); $body = $sr.ReadToEnd(); $sr.Close() } catch {}
      return [pscustomobject]@{ code = $code; body = $body }
    }
    return [pscustomobject]@{ code = 0; body = $_.Exception.Message }
  }
}

Write-Host "`n=== 1) 仓库信息 ===" -ForegroundColor Cyan
$info = Get-Url "https://api.github.com/repos/$owner/$repo"
if($info.code -eq 200){
  $j = $info.body | ConvertFrom-Json
  Write-Host ("仓库            : " + $j.full_name)
  Write-Host ("是否公开        : " + (-not $j.private))
  Write-Host ("默认分支        : " + $j.default_branch)
  Write-Host ("has_pages       : " + $j.has_pages + "   <-- true 才代表 Pages 已开启") -ForegroundColor Yellow
  Write-Host ("homepage 字段   : " + $j.homepage)
} else {
  Write-Host ("取仓库信息失败: HTTP " + $info.code) -ForegroundColor Red
  Write-Host ($info.body)
}

Write-Host "`n=== 2) 仓库默认分支的根目录文件 ===" -ForegroundColor Cyan
$c = Get-Url "https://api.github.com/repos/$owner/$repo/contents/"
if($c.code -eq 200){
  ($c.body | ConvertFrom-Json) | ForEach-Object { Write-Host ("{0,-6} {1}" -f $_.type, $_.name) }
} else {
  Write-Host ("取目录失败: HTTP " + $c.code) -ForegroundColor Red
}

Write-Host "`n=== 3) Pages 部署记录 ===" -ForegroundColor Cyan
$d = Get-Url "https://api.github.com/repos/$owner/$repo/deployments?environment=github-pages&per_page=5"
if($d.code -eq 200){
  $arr = @($d.body | ConvertFrom-Json)
  if($arr.Count -eq 0){ Write-Host "没有任何 github-pages 部署记录 → Pages 从未成功构建过" -ForegroundColor Red }
  else { $arr | ForEach-Object { Write-Host ("部署 #{0}  环境={1}  时间={2}" -f $_.id, $_.environment, $_.created_at) } }
} else { Write-Host ("取部署记录失败: HTTP " + $d.code) -ForegroundColor Red }

Write-Host "`n=== 4) 网站实际访问结果 ===" -ForegroundColor Cyan
$urls = @(
  "https://$owner.github.io/",
  "https://$owner.github.io/index.html",
  "https://$owner.github.io/%E5%A9%9A%E7%BA%B1%E7%85%A7/07ea9a8ba015f3b93068dbe7ccafbbb4.jpg"
)
foreach($u in $urls){
  $r = Get-Url $u
  $color = if($r.code -eq 200){ 'Green' } else { 'Red' }
  Write-Host ("HTTP {0,-4} {1}" -f $r.code, $u) -ForegroundColor $color
  if($r.code -ne 200){
    $t = ($r.body -replace '\s+',' ')
    if($t.Length -gt 200){ $t = $t.Substring(0,200) + '...' }
    Write-Host ("     返回内容: " + $t) -ForegroundColor DarkGray
  }
}

Write-Host "`n=== 结论对照 ===" -ForegroundColor Cyan
Write-Host "has_pages = false                  → Pages 没开启：Settings → Pages → main + / (root) → Save"
Write-Host "has_pages = true 且 3) 无部署记录   → 同上，保存后才会构建"
Write-Host "has_pages = true 且 首页 404       → 部署目录选错了：文件夹必须是 / (root)，不能是 /docs"
Write-Host "首页 200 但照片 404                → 中文目录问题，需把照片改成 photos/"
Write-Host "首页 200 全部正常                  → 之前是浏览器缓存，Ctrl+F5 或无痕窗口再看"
Write-Host ""
Write-Host "请把以上输出整段复制发给 Codex。" -ForegroundColor Yellow
