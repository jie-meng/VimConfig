# Neovim Configuration

This is a modern Lua-based Neovim configuration migrated from the original Vim configuration, maintaining the same key mappings and functionality while using a more modern plugin ecosystem.

## 🚀 Features

- 📁 **File Management**: nvim-tree (replaces NERDTree)
- 🔍 **Fuzzy Search**: Telescope (replaces fzf)
- 🎨 **Syntax Highlighting**: TreeSitter (replaces vim-polyglot)
- ⚡ **LSP Support**: Native LSP + Mason (replaces vim-lsp)
- 🔧 **Auto Completion**: nvim-cmp (replaces asyncomplete)
- 🎯 **Code Formatting**: conform.nvim (replaces manual formatting)
- 🧪 **Test Integration**: neotest (replaces vim-test)
- 📝 **Comments**: Comment.nvim (replaces nerdcommenter)
- 🎭 **Git Integration**: Gitsigns + vim-fugitive
- 🤖 **AI Assistant**: GitHub Copilot
- 🎨 **Theme**: Gruvbox + multiple alternative themes

## 📦 Plugin Mapping

| Vim Plugin | Neovim Plugin | Function |
|------------|---------------|----------|
| NERDTree | nvim-tree | File tree |
| fzf.vim | telescope.nvim | Fuzzy search |
| vim-airline | lualine.nvim | Status line |
| vim-polyglot | nvim-treesitter | Syntax highlighting |
| vim-lsp | nvim-lspconfig | LSP client |
| asyncomplete | nvim-cmp | Auto completion |
| nerdcommenter | Comment.nvim | Code comments |
| vim-test | neotest | Test runner |
| tagbar | aerial.nvim | Code outline |
| greplace | nvim-spectre | Global replace |
| vim-caser | text-case.nvim | Case conversion |
| copilot.vim | copilot.vim | AI assistant |
| a.vim | custom :A command | Header/source switch |

## 🎯 Key Mappings

Maintains the same key mappings as the original Vim configuration:

### Basic Operations
- `<Space>vs` - Vertical split window
- `<Space>hs` - Horizontal split window
- `<Leader>[` / `<Leader>]` - Switch buffers
- `mb` / `me` - Move to beginning/end of line
- `∆` / `˚` (Alt+J/K) - Move lines

### File and Search
- `<Leader>w` - Toggle file tree
- `<space>j` - Locate current file in tree
- `<space>ff` - Find files
- `<space>fg` - Find Git files
- `<space>fs` - Live grep content
- `<space>fe` - Find buffers

### Git Operations
- `<space>gs` - Git status
- `<space>gc` - Git commit
- `<space>gb` - Git blame
- `<space>gd` - Git diff
- `g[` / `g]` - Previous/next Git hunk

### LSP Operations
- `gd` - Go to definition
- `gr` - Find references
- `gi` - Go to implementation
- `K` - Hover documentation
- `<space>rn` - Rename
- `[g` / `]g` - Previous/next diagnostic

### Testing
- `<space>tn` - Run nearest test
- `<space>tf` - Run file tests
- `<space>ts` - Run test suite
- `<space>tc` - Copy test command

### Code Formatting
- `<Leader>fc` - Format code
- `<Leader>cf` - C/C++ format

### C/C++ Development
- `:A` - Switch between header (.h/.hpp) and source (.cpp/.cc/.cxx) files
- `<Leader>a` - Same as `:A` (quick switch alternate file)

### Copilot
- `<C-j>` - Accept Copilot suggestion (Insert mode)
- `<C-]>` - Next Copilot suggestion (Insert mode)
- `<C-[>` - Previous Copilot suggestion (Insert mode)
- `<C-\>` - Dismiss Copilot suggestion (Insert mode)
- `<space>ae` - Enable Copilot
- `<space>ad` - Disable Copilot
- `<space>as` - Copilot status
- `<space>ap` - Copilot panel
- `<space>au` - Copilot setup
- `<space>ao` - Copilot signout

## 🛠 Installation

### macOS
```bash
cd nvim
./install-mac.sh
```

### Ubuntu/Debian
```bash
cd nvim
./install-ubuntu.sh
```

## 🔄 Configuration Sync

### Sync configuration to system
Sync project configurations to system `~/.config/nvim/`:
```bash
./sync-to-system.sh
```

### Sync configuration from system
Sync system configurations back to project directory:
```bash
./sync-from-system.sh
```

## 📁 Directory Structure

```
nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── config/
│   │   ├── options.lua      # Basic options
│   │   ├── keymaps.lua      # Key mappings
│   │   ├── autocmds.lua     # Auto commands
│   │   └── lazy.lua         # Plugin manager setup
│   └── plugins/
│       ├── nvim-tree.lua    # File tree
│       ├── telescope.lua    # Fuzzy search
│       ├── lsp.lua          # LSP configuration
│       ├── completion.lua   # Auto completion
│       ├── git.lua          # Git integration
│       ├── formatting.lua   # Code formatting
│       ├── testing.lua      # Test integration
│       ├── colorscheme.lua  # Themes
│       ├── comment.lua      # Comment plugin
│       ├── lualine.lua      # Status line
│       ├── copilot.lua      # GitHub Copilot
│       └── utils.lua        # Other utilities
├── install-mac.sh           # macOS install script
├── install-ubuntu.sh        # Ubuntu install script
├── sync-to-system.sh        # Sync to system script
└── sync-from-system.sh      # Sync from system script
```

## 🔧 Customization

1. Modify `lua/config/options.lua` to adjust basic settings
2. Modify `lua/config/keymaps.lua` to customize key mappings
3. Add or modify plugin configurations in `lua/plugins/`
4. Run `./sync-to-system.sh` to apply changes

## 📝 Notes

1. On first startup, Lazy.nvim will automatically install all plugins
2. Some LSP servers need to be installed manually via `:Mason`
3. Restart terminal and run `nvim` to start using
4. GitHub Copilot requires authentication via `:Copilot setup` on first use

## 🤝 Differences from Vim Configuration

While functionality is basically the same, there are these main differences:

1. **Configuration Language**: Uses Lua instead of VimScript
2. **Plugin Management**: Uses lazy.nvim instead of vim-plug
3. **LSP**: Uses Neovim built-in LSP instead of vim-lsp
4. **Performance**: Overall faster startup and response times
5. **Modern**: Uses more actively maintained plugin ecosystem

## 🎉 Getting Started

After installation, run `nvim` to start using. First startup will automatically install plugins, please be patient. Enjoy the modern Neovim experience!

## 🚀 特性

- 📁 **文件管理**: nvim-tree (替代 NERDTree)
- 🔍 **模糊搜索**: Telescope (替代 fzf)
- 🎨 **语法高亮**: TreeSitter (替代 vim-polyglot)
- ⚡ **LSP 支持**: Native LSP + Mason (替代 vim-lsp)
- 🔧 **自动补全**: nvim-cmp (替代 asyncomplete)
- 🎯 **代码格式化**: conform.nvim (替代手动格式化)
- 🧪 **测试集成**: neotest (替代 vim-test)
- 📝 **注释**: Comment.nvim (替代 nerdcommenter)
- 🎭 **Git 集成**: Gitsigns + vim-fugitive
- 🎨 **主题**: Gruvbox + 多种备选主题

## 📦 插件对照表

| Vim 插件 | Neovim 插件 | 功能 |
|----------|-------------|------|
| NERDTree | nvim-tree | 文件树 |
| fzf.vim | telescope.nvim | 模糊搜索 |
| vim-airline | lualine.nvim | 状态栏 |
| vim-polyglot | nvim-treesitter | 语法高亮 |
| vim-lsp | nvim-lspconfig | LSP 客户端 |
| asyncomplete | nvim-cmp | 自动补全 |
| nerdcommenter | Comment.nvim | 代码注释 |
| vim-test | neotest | 测试运行 |
| tagbar | aerial.nvim | 代码大纲 |
| greplace | nvim-spectre | 全局替换 |
| vim-caser | text-case.nvim | 大小写转换 |

## 🎯 快捷键

保持与原 Vim 配置相同的快捷键映射：

### 基础操作
- `<Space>vs` - 垂直分割窗口
- `<Space>hs` - 水平分割窗口
- `<Leader>[` / `<Leader>]` - 切换缓冲区
- `mb` / `me` - 移动到行首/行尾
- `∆` / `˚` (Alt+J/K) - 移动行

### 文件和搜索
- `<Leader>w` - 切换文件树
- `<space>j` - 在文件树中定位当前文件
- `<space>ff` - 搜索文件
- `<space>fg` - 搜索 Git 文件
- `<space>fs` - 实时搜索内容
- `<space>fe` - 搜索缓冲区

### Git 操作
- `<space>gs` - Git 状态
- `<space>gc` - Git 提交
- `<space>gb` - Git blame
- `<space>gd` - Git diff
- `g[` / `g]` - 上/下一个 Git hunk

### LSP 操作
- `gd` - 跳转到定义
- `gr` - 查找引用
- `gi` - 跳转到实现
- `K` - 悬停文档
- `<space>rn` - 重命名
- `[g` / `]g` - 上/下一个诊断

### 测试
- `<space>tn` - 运行最近测试
- `<space>tf` - 运行文件测试
- `<space>ts` - 运行测试套件
- `<space>tc` - 复制测试命令

### 代码格式化
- `<Leader>fc` - 格式化代码
- `<Leader>cf` - C/C++ 格式化

### Copilot
- `<space>ae` - 启用 Copilot
- `<space>ad` - 禁用 Copilot
- `<space>as` - Copilot 状态

## 🛠 安装

### macOS
```bash
cd nvim
./install-mac.sh
```

### Ubuntu/Debian
```bash
cd nvim
./install-ubuntu.sh
```

## 🔄 配置同步

### 同步配置到系统
将项目中的配置同步到系统的 `~/.config/nvim/`:
```bash
./sync-to-system.sh
```

### 从系统同步配置
将系统配置同步回项目目录:
```bash
./sync-from-system.sh
```

## 📁 目录结构

```
nvim/
├── init.lua                 # 入口文件
├── lua/
│   ├── config/
│   │   ├── options.lua      # 基础选项配置
│   │   ├── keymaps.lua      # 键位映射
│   │   ├── autocmds.lua     # 自动命令
│   │   └── lazy.lua         # 插件管理器配置
│   └── plugins/
│       ├── nvim-tree.lua    # 文件树
│       ├── telescope.lua    # 模糊搜索
│       ├── lsp.lua          # LSP 配置
│       ├── completion.lua   # 自动补全
│       ├── git.lua          # Git 集成
│       ├── formatting.lua   # 代码格式化
│       ├── testing.lua      # 测试集成
│       ├── colorscheme.lua  # 主题
│       ├── comment.lua      # 注释插件
│       ├── lualine.lua      # 状态栏
│       └── utils.lua        # 其他实用插件
├── install-mac.sh           # macOS 安装脚本
├── install-ubuntu.sh        # Ubuntu 安装脚本
├── sync-to-system.sh        # 同步到系统脚本
└── sync-from-system.sh      # 从系统同步脚本
```

## 🔧 自定义

1. 修改 `lua/config/options.lua` 来调整基础设置
2. 修改 `lua/config/keymaps.lua` 来自定义快捷键
3. 在 `lua/plugins/` 目录下添加或修改插件配置
4. 运行 `./sync-to-system.sh` 应用更改

## 📝 注意事项

1. 首次启动 Neovim 时，Lazy.nvim 会自动安装所有插件
2. 某些 LSP 服务器需要通过 `:Mason` 手动安装
3. 重启终端并运行 `nvim` 即可使用
4. Python 和 Node.js 环境需要正确配置以支持格式化工具

## 🤝 与 Vim 配置的区别

虽然功能基本相同，但有以下主要区别：

1. **配置语言**: 使用 Lua 而不是 VimScript
2. **插件管理**: 使用 lazy.nvim 而不是 vim-plug
3. **LSP**: 使用 Neovim 内置 LSP 而不是 vim-lsp
4. **性能**: 整体启动速度和响应速度更快
5. **现代化**: 使用更活跃维护的插件生态

## 🎉 开始使用

安装完成后，运行 `nvim` 即可开始使用。首次启动会自动安装插件，请耐心等待。享受现代化的 Neovim 体验！
