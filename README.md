<h1 align="center">Always Be Sessioning</h1>
<p align="center">Keeps a Claude Code session window open at all times.</p>

<hr/>

### The problem

Claude Code tracks two quotas: a five-hour session and a weekly limit. The five-hour timer starts with your first message, not when you need it. If you don't send a message, the timer doesn't start, and you lose the time you could have used.

### The solution

Always Be Sessioning runs a small daemon that pings Claude Code every five hours, keeping a session window open.

### Installation

```bash
curl -fsSL https://raw.githubusercontent.com/jeremysball/always-be-sessioning/main/install.sh | bash
```

This installs `abs` to `~/.local/bin/abs`. Re-running it upgrades an existing install.

### Usage

```bash
abs run    # start the daemon
abs logs   # view the daemon's log
```

`run` starts the daemon and should be run in the background, using a process supervisor, `tmux`, `nohup`, or the systemd service below. `logs` opens
`${XDG_STATE_HOME:-$HOME/.local/state}/abs/abs.log` in your pager. Each line records a timestamp and whether that cycle's ping succeeded.

### PATH setup

If `abs` isn't found after installing, add `~/.local/bin` to your `PATH`:

- **bash**: add `export PATH="$HOME/.local/bin:$PATH"` to `~/.bashrc`.
- **zsh**: add `export PATH="$HOME/.local/bin:$PATH"` to `~/.zshrc`.
- **fish**: run `fish_add_path ~/.local/bin`.

### Auto-starting from your shell config

To start `abs run` from your shell's startup file instead of using systemd, guard it so a new shell doesn't spawn duplicates:

**fish**, in `~/.config/fish/config.fish`, inside `if status is-interactive`:

```fish
if not pgrep -f "abs run" >/dev/null
    abs run &>/dev/null & disown
end
```

**bash**, in `~/.bashrc`:

```bash
if [[ $- == *i* ]] && ! pgrep -f "abs run" >/dev/null; then
    nohup abs run >/dev/null 2>&1 &
    disown
fi
```

This starts the daemon when a shell opens, not on boot. Use the systemd service below to run it independently of any shell session.

### Running as a systemd service

```bash
mkdir -p ~/.config/systemd/user
curl -fsSL https://raw.githubusercontent.com/jeremysball/always-be-sessioning/main/systemd/abs.service \
  -o ~/.config/systemd/user/abs.service
systemctl --user enable --now abs.service
```

This starts `abs run` on boot and restarts it on failure. Check status with `abs logs`. The service doesn't need separate logging; `abs run` writes to the log file regardless of how it's launched.

### Configuration

| Variable       | Default | Description                                      |
| -------------- | ------- | ------------------------------------------------ |
| `ABS_INTERVAL` | `5h`    | How often to ping, passed directly to `sleep`.   |

### Requirements

The `claude` CLI, installed and authenticated. `abs` runs `claude --print "."` on a timer and doesn't handle login.

<hr/>

<p align="center">Copyright (c) 2026, @jeremysball, MIT License</p>
