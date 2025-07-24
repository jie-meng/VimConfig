# 简化版 Neovim 配置

## 已移除的依赖
- ❌ Git
- ❌ Node.js
- ❌ Python3
- ❌ autopep8
- ❌ prettier  
- ❌ tree-sitter-cli
- ❌ lazygit
- ❌ Nerd Font
- ❌ nvim-web-devicons

# 简化版 Neovim 配置

## 已移除的依赖
- ❌ Git
- ❌ Node.js
- ❌ Python3
- ❌ autopep8
- ❌ prettier  
- ❌ tree-sitter-cli
- ❌ lazygit
- ❌ Nerd Font (不需要安装特殊字体)
- ❌ nvim-web-devicons (不需要文件类型图标)

## 使用的 Unicode 字符

### 文件树 (nvim-tree)
- `▶` 收起文件夹
- `▼` 展开文件夹
- 保留 Git 状态标识：`✗` `✓` `★` `➜` 等

### 状态栏 (lualine)
- 纯文本显示，无特殊图标

### Git 标识 (gitsigns)
- `│` 新增/修改行
- `_` 删除行
- `‾` 顶部删除
- `~` 修改删除
- `┆` 未跟踪文件

### LSP 诊断
- `✗` 错误
- `⚠` 警告
- `💡` 提示
- `ℹ` 信息

### 代码补全
使用 emoji 图标，在大多数终端中都能正常显示：
- `📝` Text
- `⚡` Method/Event
- `ƒ` Function
- `🏗` Constructor/Struct
- `🏷` Field
- `📦` Variable
- `🏛` Class
- `🔌` Interface
- `📁` Module
- `🔧` Property
- `📏` Unit
- `💎` Value
- `📋` Enum
- `🔑` Keyword
- `✂` Snippet
- `🎨` Color
- `📄` File
- `👀` Reference
- `📂` Folder
- `📑` EnumMember
- `🔒` Constant
- `➕` Operator
- `📝` TypeParameter

### 测试结果 (neotest)
- `✓` 通过
- `●` 运行中
- `✗` 失败
- `○` 跳过
- `?` 未知

### Telescope
- `🔍 ` 搜索提示符
- `❯ ` 选择标识

## 安装方式

只需要 Neovim 本身，无需额外字体或工具：

```bash
# macOS
./install-mac.sh

# Ubuntu
./install-ubuntu.sh
```

配置会自动下载并配置所有必要的插件，完全独立运行。
