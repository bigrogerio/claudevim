# claudevim

Minimal Neovim distribution with Claude Code embedded.

Inspired by the layout and school of LazyVim, but without depending on it:
hand-rolled stack on top of `lazy.nvim` with ~7 carefully chosen plugins.

## Layout

On launch, two vertical panes:

- **Left** (~60%): editor.
- **Right** (~40%): terminal running `claude`.

The file explorer (neo-tree) opens and closes on demand via `<leader>e`.

## Installation

```bash
git clone <this repo> ~/coding/claudevim
cd ~/coding/claudevim
./install.sh
```

Creates two symlinks:

- `~/.config/claudevim` -> `<repo>/nvim`
- `/opt/homebrew/bin/claudevim` -> `<repo>/bin/claudevim`

Requirements:

- `nvim >= 0.10`
- `claude` on PATH
- `git`
- A **Nerd Font** configured in your terminal — the dashboard and file
  explorer use Nerd Font glyphs (icons for "find file", "recent files", a
  little robot for the claude entry, etc.). Without it those icons render as
  empty boxes. JetBrains Mono, FiraCode, Hack — pick any from
  [nerdfonts.com](https://www.nerdfonts.com/) and set it as your terminal
  font.

On first run, `lazy.nvim` automatically downloads the plugins.

## Usage

```bash
claudevim                        # default claude code
claudevim --resume               # forwards --resume to claude
claudevim --model claude-opus-4-7
```

All arguments are forwarded to `claude`. Neovim itself receives no arguments.

### Adjusting the split ratio

By default, the editor and the claude pane each take 50% of the screen. To
change that, set `vim.g.claudevim_split_ratio` in
`~/.config/claudevim/lua/config/options.lua` (the value is the fraction
occupied by the **claude** pane):

```lua
vim.g.claudevim_split_ratio = 0.4   -- claude 40%, editor 60%
vim.g.claudevim_split_ratio = 0.6   -- claude 60%, editor 40%
```

Clamped between 0.2 and 0.8 so you don't accidentally hide a pane. You can
also resize on the fly with the standard nvim window keys: `<C-w>>` and
`<C-w><` to grow or shrink the focused pane.

## Essential keymaps

| Key | Action |
|---|---|
| `<leader>e` | Toggle file explorer |
| `<leader>cc` | Focus claude pane (enter terminal mode) |
| `<leader>ce` | Focus editor pane |
| `<leader>cr` | Restart claude |
| `<C-h/j/k/l>` | Window navigation (works in terminal mode) |
| `<Esc><Esc>` | Exit terminal mode |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>w` | Save |
| `<leader>q` | Quit all |

`<leader>` is the spacebar.

### A note on `<leader>` and the claude pane

When the cursor is inside the claude pane, you're in **terminal mode**: every
keystroke is forwarded to claude code. This includes the spacebar, so
`<leader>` mappings (`<Space>cc`, `<Space>e`, `<Space>ff`, …) **do not fire**
from there — they get typed into claude's prompt instead.

Only the keymaps explicitly bound in terminal mode survive that pane:

- `<C-h/j/k/l>` — window navigation (the most useful one: `<C-h>` jumps to
  the editor and drops you back into normal mode in one shot).
- `<Esc><Esc>` — exit terminal mode without leaving the pane (then
  `<leader>` mappings work, but you stay focused on the claude pane).

The intended ergonomic flow:

- For commands that act on the editor (open file, grep, file explorer),
  press `<C-h>` first to jump back, then use `<Space>...`.
- For commands that act on the claude pane itself, the dedicated terminal-mode
  shortcuts are enough.

If a specific `<leader>` action would be useful directly from inside the
claude pane, it can be added as a terminal-mode mapping — at the cost of
making that key combo unreachable to claude code.

## Stack

- `lazy.nvim` — plugin manager
- `tokyonight.nvim` — colorscheme
- `lualine.nvim` — statusline
- `which-key.nvim` — keymap discovery
- `neo-tree.nvim` — file explorer
- `nvim-treesitter` — syntax highlighting
- `telescope.nvim` — fuzzy finder
- `gitsigns.nvim` — git markers in the gutter

No LSP, no autocomplete, no mason. Claude does the heavy lifting.

## Layout

```
nvim/
├── init.lua
└── lua/
    ├── config/        # options, lazy, keymaps, autocmds
    ├── plugins/       # plugin specs
    └── claudevim/     # layout + claude integration
```

## Architecture

claudevim is not a Neovim plugin and not a fork. It's a **second
configuration instance** of the same `nvim` binary, activated through an
environment variable. That changes what gets loaded, but not what runs.

The flow of a single invocation is direct:

1. You run `claudevim --resume` in the shell.
2. The shim at `/opt/homebrew/bin/claudevim` does three things: sets
   `NVIM_APPNAME=claudevim`, exports `CLAUDEVIM_CLAUDE_ARGS="--resume"`, and
   `exec`s `nvim` with no arguments.
3. Neovim, on startup, sees `NVIM_APPNAME=claudevim` and switches its
   configuration lookup path: instead of `~/.config/nvim/`, it reads from
   `~/.config/claudevim/`. The cache, plugins installed by `lazy.nvim`, and
   undo files also stay isolated under `~/.local/share/claudevim/` and
   `~/.local/state/claudevim/`.
4. `init.lua` loads options, bootstraps `lazy.nvim`, registers keymaps and
   autocmds, and calls `require("claudevim").setup()`.
5. `setup()` registers a `VimEnter` autocmd that, once the editor finishes
   initializing, opens a vertical split on the right and runs `:terminal
   claude <args>` there, with the args read from the env var.
6. The editor window stays on the left and keeps focus; the claude window is
   on the right, ready for interaction.

```
                  shell
                    │
                    ▼
   /opt/homebrew/bin/claudevim   (bash shim)
                    │  sets NVIM_APPNAME=claudevim
                    │  exports CLAUDEVIM_CLAUDE_ARGS=$*
                    │  exec nvim
                    ▼
                  nvim
                    │  reads config from ~/.config/claudevim/  (symlink → repo/nvim)
                    │  lazy.nvim installs plugins under ~/.local/share/claudevim/
                    ▼
            ┌───────────────────────────────────┐
            │  editor (~60%)  │  :terminal       │
            │                 │  claude --resume │
            │  buffers,       │  (real claude    │
            │  treesitter,    │   code           │
            │  telescope,     │   subprocess —   │
            │  neo-tree…      │   same UX as     │
            │                 │   the CLI)       │
            └───────────────────────────────────┘
```

## Why we don't touch `~/.config/nvim`

This is probably the most important decision in the project, and it deserves
an explanation, because the natural temptation would be to add the integration
to your existing nvim setup.

**Your current config stays untouched.** claudevim and your daily LazyVim
coexist as two independent Neovim installations. `nvim` keeps opening LazyVim
with all your plugins, LSP, autocomplete, mason. `claudevim` opens a separate
installation with a different plugin set, different cache, different lockfile.
No cross dependencies.

**The mechanism is `NVIM_APPNAME`**, supported natively since Neovim 0.9.
Neovim resolves its config paths through XDG, and `NVIM_APPNAME` substitutes
the string `nvim` in all of them. The default is `nvim`, which produces
`~/.config/nvim`, `~/.local/share/nvim`, `~/.local/state/nvim`. With
`NVIM_APPNAME=claudevim`, those become `~/.config/claudevim`,
`~/.local/share/claudevim`, and so on. It's a clean redirection at the XDG
level, not a runtime-path hack.

Why this matters, in decreasing order of relevance:

**1. You don't risk your primary workflow.** If we had added the embedded
claude logic to your LazyVim, any bug here would affect your daily editor.
With NVIM_APPNAME, a broken plugin in claudevim cannot stop you from opening
a file with `nvim`.

**2. The two configs evolve at different paces.** Your LazyVim receives
upstream updates (from the LazyVim project) that change behavior, add
keymaps, bump plugins. claudevim is hand-rolled and moves at our own pace,
with its own `lazy-lock.json`. Mixing the two would force you to sync two
maintenance timelines inside the same config file.

**3. claudevim can be genuinely minimal.** Because it lives in a separate
instance, it can ignore LSP, autocomplete, mason — things you'd miss in the
daily editor. The result is a faster startup and an entire config that fits
in a small handful of files.

**4. Plugins live in separate namespaces.** claudevim's `lazy.nvim` stores
plugins under `~/.local/share/claudevim/lazy/`, never competing with the ones
in `~/.local/share/nvim/lazy/` of your main config. Same plugin, two distinct
installations, two distinct lockfiles.

**5. Uninstalling is trivial.** `rm` the two symlinks that `install.sh`
created and claudevim is gone — no leftover trace in your main config.

The alternative — shipping the feature as a plugin inside LazyVim — looked
tempting but carried a high cost: you'd take on responsibility for
compatibility with everything LazyVim already loads, and you'd lose the
ability to keep a "stripped-down" nvim dedicated to this mode of use. As you
yourself raised during the conversation, keeping pace with LazyVim is already
a maintenance cost; multiplying that by compatibility with our own logic
would only make it worse. NVIM_APPNAME solves it without a trade-off: you
gain a new, separate nvim without losing the old one.
