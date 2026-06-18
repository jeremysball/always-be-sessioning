<h1 align="center">Always Be Sessioning</h1>
<p align="center">Keep your Claude Code five-hour session window always ticking.</p>

<hr/>

### The problem

When using Claude Code there are two quotas: the five hour session and the week. The five
hour session doesn't start until you send your first request, so you can end up in a
situation where if you'd sent a single message four hours ago, you'd have a refresh in just
one hour. Instead, the timer never started, and now it only begins ticking down once you
actually need it.

### The solution

A small daemon that runs in the background and periodically calls Claude Code to trigger a
session. Just a single invocation every five hours, so a session window is always open and
ready when you need it.

### Installation

```bash
curl -fsSL https://raw.githubusercontent.com/jeremysball/always-be-sessioning/main/install.sh | bash
```

This installs `abs` to `~/.local/bin/abs`. Re-running it upgrades an existing install.

### Usage

```bash
abs run    # start the daemon loop
abs logs   # follow the daemon's log
```

`run` is meant to be left running in the background (under a process supervisor, `tmux`,
`nohup`, or the systemd service below). `logs` tails
`${XDG_STATE_HOME:-$HOME/.local/state}/abs/abs.log`, where each line records a timestamp and
whether that cycle's ping succeeded.

### PATH setup

If `abs run`/`abs logs` aren't found after installing, `~/.local/bin` isn't on your `PATH`
yet:

- **bash**: add `export PATH="$HOME/.local/bin:$PATH"` to `~/.bashrc`.
- **zsh**: add `export PATH="$HOME/.local/bin:$PATH"` to `~/.zshrc`.
- **fish**: run `fish_add_path ~/.local/bin`.

### Running as a systemd service

To have `abs run` start automatically and restart if it ever fails:

```bash
mkdir -p ~/.config/systemd/user
curl -fsSL https://raw.githubusercontent.com/jeremysball/always-be-sessioning/main/systemd/abs.service \
  -o ~/.config/systemd/user/abs.service
systemctl --user enable --now abs.service
```

Check on it with `abs logs` as usual; the service itself doesn't need separate logging since
`abs run` already writes to the log file regardless of how it's launched.

### Configuration

| Variable       | Default | Description                                |
| -------------- | ------- | -------------------------------------------- |
| `ABS_INTERVAL` | `5h`    | How often to ping, passed straight to `sleep`. |

### Requirements

The `claude` CLI, installed and already authenticated. `abs.sh` only runs
`claude --print "."` on a timer; it doesn't handle login.

<hr/>

<p align="center">Copyright (c) 2026, @jeremysball, MIT License</p>
