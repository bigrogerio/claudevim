<img width="2535" height="1369" alt="image" src="https://github.com/user-attachments/assets/64bf477a-ca44-4b1c-9a6d-2c69516d0f9f" />

# claudevim

Minimal Neovim distribution with Claude Code embedded.

Inspired by the layout and school of LazyVim, but without depending on it:
hand-rolled stack on top of `lazy.nvim` with ~7 carefully chosen plugins.

## Never used vim? You'll be fine.

vim has a reputation, and most of it comes from maximalist setups out
there — hundreds of keymaps, a wall of plugins, configs that take a
weekend to read. claudevim is the opposite: a deliberate subset. There's
no LSP, no autocomplete, no mason. The keymap surface fits in a small
table, and which-key shows you the table whenever you press `<Space>`.

The minimum to be productive on day one:

- `i` to start typing, `<Esc>` to stop.
- `:w` to save, `:wq` to save and quit.
- `<Space>e` opens the file explorer; `<Space>ff` finds a file by name.
- `<C-h>` jumps to the editor; `<C-l>` jumps to claude.

That's a five-minute curve. The rest you pick up by use, and claude is in
the next pane to teach you on demand: stuck on a vim command? `<C-l>`,
ask, get the answer next to your code. In that sense claudevim is a
*kinder* introduction to vim than installing the editor on its own — the
usual stumbling blocks (finding files, navigating windows, getting
unstuck) are handled by neo-tree, telescope, and three Ctrl bindings.

### Why a terminal-native editor beats a heavy IDE

Even if VS Code or JetBrains is your comfort zone, terminal-native has
real edges that compound:

- **claude code lives in the terminal.** That's where it was designed to
  run. Inside an IDE you either Alt-Tab to a terminal or use a plugin
  that adds a translation layer with its own latency and quirks.
  claudevim removes the gap.
- **Lighter, faster, quieter.** No Electron, no JVM. Startup in
  hundreds of milliseconds, RAM cost a fraction of a full IDE. Your
  laptop fan stops mattering.
- **Composable with your shell.** `cd` into a project, run `claudevim`,
  work. No "open workspace", no "trust this folder", no interpreter
  selection. The shell skills you have everywhere keep working here.
- **Travels over SSH.** Same setup runs on a remote server with no
  remote-protocol layer in between. Open a tmux on a beefy machine, run
  claudevim, develop as if local.
- **Quiet UI.** No notifications, no "extension X needs updating", no
  popups. The screen is your code and claude.

You don't have to abandon your IDE — some workflows still want the heavy
kit. But for the largest single use case ("write code, ask claude"),
claudevim is faster, lighter, and closer to the metal.

## Layout

On launch, two vertical panes:

- **Left** (~60%): editor.
- **Right** (~40%): terminal running `claude`.

The file explorer (neo-tree) opens and closes on demand via `<leader>e`.

## Installation

```bash
git clone https://github.com/bigrogerio/claudevim.git ~/coding/claudevim
cd ~/coding/claudevim
./install.sh
```

(SSH alternative: `git clone git@github.com:bigrogerio/claudevim.git ~/coding/claudevim`.)

Creates two symlinks:

- `~/.config/claudevim` -> `<repo>/nvim`
- `/opt/homebrew/bin/claudevim` -> `<repo>/bin/claudevim`

The clone target doesn't have to be `~/coding/claudevim` — pick any path. The
`install.sh` symlinks from wherever the repo lives.

Requirements:

- `nvim >= 0.12`
- `claude` on PATH
- `git`
- `tree-sitter` CLI (`brew install tree-sitter-cli` on macOS) — used by
  nvim-treesitter to compile syntax-highlighting parsers from source on
  first run. Without it, `:TSUpdate` fails and you'll see plain-text
  buffers without highlights.
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

## claudevim as a markdown reader

A common use case in practice: opening claudevim on a project just to read
its docs — README, design notes, ADRs, library guides — alongside claude.
It does that well, even though it's not a dedicated markdown viewer like
[charmbracelet/glow](https://github.com/charmbracelet/glow).

The honest trade-off up front: **glow renders**. It turns `# Heading` into
a styled heading, `**bold**` into bold, fenced code into syntax-coloured
boxes; the output is a typeset page in the terminal. **claudevim shows
source** — raw markdown with treesitter highlighting on the syntactic
markers. If your goal is to *read prose pleasantly*, glow wins on
typography.

The case for claudevim isn't about prettier rendering. It's about what
sits next to the document:

- **Claude Code, on the same screen.** The single biggest gain over a
  pure renderer. You're reading a section of a guide and something is
  unclear? `<C-l>` and ask. The doc stays visible, the answer comes in the
  pane next to it. No copy-paste, no tab-switching, no "let me ask
  somewhere else."
- **A file explorer for documentation trees.** Real-world docs aren't
  one-file affairs — they're folders of `.md` under `docs/`, design notes
  scattered across a repo, ADRs in dated subdirectories. `<Space>e` walks
  the tree without leaving the reader.
- **`<Space>fg` (live grep) across all docs.** Finding the right paragraph
  in a 30-file documentation set is instant.
- **Edits on the fly.** Reading a doc and noticing a typo, an outdated
  command, a missing note? You're already in an editor. Fix it, save,
  move on.

Where glow keeps its edge: launch on one file and read. Single binary, no
setup, no dependency tree. For *that* workflow it's better, full stop.

claudevim makes a different bet — that for developers, documentation is
read **while doing something else**: writing code, asking questions,
cross-referencing. In that context, putting the doc next to a code-aware
AI and a project file tree beats a prettier prose renderer.

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
