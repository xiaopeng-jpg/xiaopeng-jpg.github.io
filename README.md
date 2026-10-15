# xiaopeng-jpg.github.io

我们的婚纱照纪念页 · 蓝色夜空 + 暖金色调，纯 HTML + CSS（无框架、无 JS、无外部依赖）。

- 线上地址：https://xiaopeng-jpg.github.io/
- 首页文件：`index.html`
- 照片目录：`婚纱照/`（页面里用百分号编码 `%E5%A9%9A%E7%BA%B1%E7%85%A7/` 引用，避免中文路径兼容问题）

## 怎么更新内容

1. 换照片：把新图放进 `婚纱照/`，打开 `index.html` 替换对应 `<img>` 的 `src` 文件名。
2. 改名字：`index.html` 里搜索「新郎」即可（首屏和信卡片两处）。
3. 改文案：各区块的 `h2`、`lead`、`quote` 都是直接可改的中文。
4. 改完提交：双击 `deploy.bat`（需要已安装 Git），或用 GitHub Desktop，或在网页上重新上传。

## 怎么发布（三种方式，选一种）

### 方式一：网页上传（不用装任何软件，最省事）
1. 打开 https://github.com/xiaopeng-jpg/xiaopeng-jpg.github.io
   （如果仓库还不存在：右上角 + → New repository，名字填 `xiaopeng-jpg.github.io`，选 Public，创建）
2. 点 `Add file` → `Upload files`，把 `index.html`、`.nojekyll`、`README.md` **和整个 `婚纱照` 文件夹**一起拖进去
   （`婚纱照` 文件夹要在网页上传框里拖，浏览器会自动展开文件夹；`.preview` 文件夹不要传）
3. 下方点 `Commit changes`
4. 进入 `Settings` → 左侧 `Pages` → Source 选 **Deploy from a branch**，Branch 选 `main` + `/ (root)` → `Save`
5. 等 1~2 分钟，访问 https://xiaopeng-jpg.github.io/

### 方式二：GitHub Desktop（图形界面，推荐经常更新的人）
1. 安装 https://desktop.github.com/
2. `File` → `Add local repository` → 选择本文件夹 → 如果提示不是仓库，点 `create a repository` 在这里
3. 左下角填一句提交说明 → `Commit to main` → `Publish repository`（仓库名必须是 `xiaopeng-jpg.github.io`）
4. 之后按方式一第 4 步开启 Pages

### 方式三：命令行一键发布
1. 安装 Git：https://git-scm.com/download/win
2. 双击本文件夹里的 `deploy.bat`
   - 它会自动 `init → commit → 推送到 main`，如果装了 GitHub CLI 还会自动开启 Pages
   - 想让它顺带自动开 Pages：`winget install GitHub.cli` 然后 `gh auth login`
