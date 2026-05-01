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
- 🤖 **AI Assistant**: GitHub Copilot / Minuet AI (switchable)
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
- `<Space>sv` - Vertical split window
- `<Space>sh` - Horizontal split window
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

### Markdown Helpers (markdown buffers only)

All markdown mappings live under `<Leader>m` (buffer-local).

#### Image Paste & Resize (Typora-style)

Workflow: drag an image file onto the markdown buffer (or paste a path).
Place the cursor on that line and press `<Leader>mi` — the path will be
recognized, the file copied into `<basename>.assets/`, and the line
rewritten as `![alt](<basename>.assets/file.ext)`.

- `<Leader>mi` - **Paste image**. Reads the current line, finds an image
  path, copies it into `<basename>.assets/` next to the current `.md`
  file, and replaces the path with a Markdown image link.

  Recognized inputs on the line (in priority order):
    1. an existing `![alt](path)` link
    2. an existing `<img src="...">` tag
    3. a bare absolute path (`/Users/...`, `~/Downloads/...`)
    4. a `file://` URL (percent-decoded)

  Image detection: extension whitelist (`png/jpg/jpeg/gif/webp/bmp/svg/`
  `tiff/tif/ico/avif/heic/heif`, **case-insensitive** — `PNG`, `Png`,
  `png` all work). If the extension is missing or unusual, the file is
  also content-sniffed via magic numbers.

- `<Leader>mz` - **Picture zoom**. Resize the image reference on the
  current line. Prompts for a zoom percentage (default `50`) and rewrites
  the line as `<img src="..." alt="..." style="zoom:NN%;" />`. Works on
  both `![alt](path)` and existing `<img ...>` tags.

The on-disk layout matches Typora exactly, so the same files render in
both Typora and `:MarkdownPreviewToggle`.

#### Insert Table

- `<Leader>mt` - **Insert table**. Prompts for dimensions in `rows x cols`
  format (e.g. `3x4`), inserts a markdown table at the cursor position,
  and enters insert mode on the first header cell.

#### Cleanup Unused Assets

- `<Leader>md` - **Delete unused assets**. Scans the `<basename>.assets/`
  directory, finds files not referenced in the current document, lists
  them, and prompts for confirmation before deleting.

### AI Providers
The configuration supports two AI completion providers:
- **Copilot**: GitHub's cloud-based AI (requires authentication)
- **Minuet**: Local AI with Ollama (requires local Ollama setup)

#### AI Completion Provider Management
- `<Leader>At` - Toggle between Copilot and Minuet
- `<Leader>As` - Show current AI completion provider status
- `<Leader>Ac` - Switch to Copilot
- `<Leader>Am` - Switch to Minuet
- `:AICompletionProviderSwitch` - Toggle AI completion provider
- `:AICompletionProviderSwitch copilot` - Switch to Copilot
- `:AICompletionProviderSwitch minuet` - Switch to Minuet
- `:AICompletionProviderStatus` - Show current provider

#### Copilot (when active)
- `<Tab>` - Accept Copilot suggestion (Insert mode)
- `<C-.>` - Next Copilot suggestion (Insert mode)
- `<C-,>` - Previous Copilot suggestion (Insert mode)
- `<C-/>` - Dismiss Copilot suggestion (Insert mode)
- `<space>Ce` - Enable Copilot
- `<space>Cd` - Disable Copilot
- `<space>Cs` - Copilot status
- `<space>Cp` - Copilot panel
- `<space>Ca` - Copilot auth
- `<space>Co` - Copilot signout

#### Minuet (when active)
- `<C-l>` - Accept Minuet suggestion (Insert mode)
- `<C-=>` - Next Minuet suggestion (Insert mode)
- `<C-->` - Previous Minuet suggestion (Insert mode)
- `<C-i>` - Dismiss Minuet suggestion (Insert mode)

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

This script performs a direct overwrite update (no backup is created).

## 📁 Directory Structure

```
nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── config/
│   │   ├── options.lua                 # Basic options
│   │   ├── keymaps.lua                 # Key mappings
│   │   ├── autocmds.lua                # Auto commands
│   │   ├── ai_completion_provider.lua  # AI completion provider manager
│   │   ├── markdown.lua             # Markdown helpers (image, table)
│   │   └── lazy.lua                    # Plugin manager setup
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
│       ├── minuet.lua       # Minuet AI (Ollama)
│       └── utils.lua        # Other utilities
├── install-mac.sh           # macOS install script
├── install-ubuntu.sh        # Ubuntu install script
└── sync-to-system.sh        # Sync to system script (direct overwrite)
```

## 🔧 Customization

1. Modify `lua/config/options.lua` to adjust basic settings
2. Modify `lua/config/keymaps.lua` to customize key mappings
3. Add or modify plugin configurations in `lua/plugins/`
4. Run `./sync-to-system.sh` to apply changes

## 📝 Notes

1. On first startup, Lazy.nvim will automatically install all plugins
2. Core language servers (Lua, TypeScript, Python, C/C++) will be installed automatically
3. Additional language servers (Rust, Go, etc.) can be installed manually via `:Mason`
4. Restart terminal and run `nvim` to start using
5. **AI Providers**:
   - By default, **Copilot** is enabled
   - GitHub Copilot requires authentication via `:Copilot auth` on first use
   - To use Minuet, install Ollama first: https://ollama.ai/
   - Switch providers with `<Leader>At` or `:AICompletionProviderSwitch`
   - The selected provider is saved and persists across Neovim restarts
   - After switching providers, restart Neovim for changes to take effect

## 🤝 Differences from Vim Configuration

While functionality is basically the same, there are these main differences:

1. **Configuration Language**: Uses Lua instead of VimScript
2. **Plugin Management**: Uses lazy.nvim instead of vim-plug
3. **LSP**: Uses Neovim built-in LSP instead of vim-lsp
4. **Performance**: Overall faster startup and response times
5. **Modern**: Uses more actively maintained plugin ecosystem

## 🎉 Getting Started

After installation, run `nvim` to start using. First startup will automatically install plugins, please be patient. Enjoy the modern Neovim experience!
