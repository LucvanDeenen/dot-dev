# dot-dev

A cross-platform dotfiles setup tool. Clone this repo, point it at your personal config repo (`dot-conf`), and run `setup.sh` to configure your machine.

## Prerequisites

- Bash (Git Bash on Windows, native on macOS/Linux)
- A `dot-conf` repository containing your personal configuration (see below)

## Quick start

```bash
git clone https://github.com/<you>/dot-dev ~/repos/dot-dev
git clone https://github.com/<you>/dot-conf ~/repos/dot-conf
cd ~/repos/dot-dev
bash setup.sh
```

By default `dot-conf` is expected at `$HOME/repos/dot-conf`. Override with an env var:

```bash
DOT_CONF_DIR=/path/to/your/dot-conf bash setup.sh
```

---

## dot-conf

`dot-conf` is a **separate, private** repository that holds all your personal configuration files. `dot-dev` never ships config — it only reads from whatever path `DOT_CONF_DIR` points to.

### Expected structure

```
dot-conf/
├── git/
│   ├── .gitconfig                  # Global git identity & settings
│   └── repos/
│       └── workspace/
│           └── .gitconfig-work     # Work-specific git identity (conditional include)
├── cli/
│   └── .cli/
│       ├── .cli_profile            # Sourced by .bashrc on every shell start
│       ├── alias/
│       │   ├── common.sh           # Shared aliases
│       │   └── *.sh                # Any additional alias files
│       └── functions/
│           └── *.sh                # Shell functions
├── nuget/
│   └── nuget.tar.gz                # NuGet CLI binary (Windows)
└── ocp/
    └── oc.tar.gz                   # OpenShift CLI binary
```

### git/

Global git configuration copied into `$HOME`.

**`git/.gitconfig`** — minimum required fields:

```ini
[user]
    name  = Your Name
    email = your@email.com
[core]
    autocrlf = input
```

Add a conditional include for a work identity if you use a separate git profile for a work workspace:

```ini
[includeIf "gitdir:~/repos/workspace/"]
    path = ~/repos/workspace/.gitconfig-work
```

**`git/repos/workspace/.gitconfig-work`:**

```ini
[user]
    name  = Your Name
    email = you@company.com
```

### cli/

CLI tooling copied into `$HOME`. The `.cli_profile` file is automatically appended to `.bashrc` during setup so it loads on every new shell.

**`cli/.cli/.cli_profile`** — entry point, source your alias and function files here:

```bash
for f in "$HOME/.cli/alias/"*.sh; do source "$f"; done
for f in "$HOME/.cli/functions/"*.sh; do source "$f"; done
```

**`cli/.cli/alias/common.sh`** — general aliases:

```bash
alias ll='ls -lah'
alias gs='git status'
```

Add as many `*.sh` files under `alias/` and `functions/` as you like — they are all sourced automatically.

### nuget/ and ocp/

Place the CLI binaries as `.tar.gz` archives. They are extracted into `$HOME/bin` during setup.

- `nuget/nuget.tar.gz` — NuGet CLI (Windows only)
- `ocp/oc.tar.gz` — OpenShift `oc` CLI

---

## Repository layout

```
dot-dev/
├── env.sh              # Path config — sets ROOT_DIR, SCRIPTS_DIR, DOT_CONF_DIR
├── setup.sh            # Entry point
├── app/
│   ├── scripts/        # One script per setup task, shown in the selection menu
│   ├── src/            # Core app logic (menu, runner, profile, alias registration)
│   └── utils/          # Shared helpers (OS detect, icon, CLI install, …)
└── conf/               # Reserved — intentionally empty, content lives in dot-conf
```
