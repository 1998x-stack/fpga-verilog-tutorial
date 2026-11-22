# 迁移设计说明

旧目录：28 篇正文、根目录 index、theme.css、courses.json 全平铺。新目录将网站入口与文章、素材、可执行实验、事实来源分离。

| 原路径 | 新规范路径 | 兼容 |
|---|---|---|
| `/index.html` | `/index.html` | 原地址原位替换 |
| `/01.html` 至 `/28.html` | `/chapters/01.html` 至 `/chapters/28.html` | 旧地址保留 HTML meta refresh 与手动链接 |
| `/theme.css` | `/assets/css/legacy.css` | 原路径保留、旧章节复制到 `/chapters/theme.css` |
| `/courses.json` | `/data/courses.json` | 原路径保留 |

目前已重写 01—15。16—28 的 HTML 内容不改动，只在新路径复用 Git blob。其旧页目录链接在 `chapters/` 内继续相互指向，目录入口由 `chapters/index.html` 回到网站首页。

Pages：`main` 推送后由 `.github/workflows/pages.yml` 部署静态根目录，仓库 GitHub Pages 设置需要选用 GitHub Actions。不能把配置提交当作上线验证。
