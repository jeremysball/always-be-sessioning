<h1 align="center">Always Be Sessioning</h1>
<p align="center">Keeps a Claude Code session window open at all times.</p>

<hr/>

### The problem

Claude Code tracks two quotas: a five-hour session and a weekly limit. The five-hour timer starts with your first message, not when you need it. If you don't send a message, the timer doesn't start, and you lose the time you could have used.

This is a particular problem if you're running Claude Code inside Docker, which is common for devcontainers and sandboxed setups. A container usually has no init system: no systemd, nothing to hand a timer to. You can't just schedule a job and walk away the way you could on a regular host.

### The solution

Always Be Sessioning is a small daemon: a shell script with a sleep loop, nothing more. It pings Claude Code every five hours to keep a session window open, and it runs as an ordinary process, so it works inside a plain Docker container with no init system at all. If your host does have systemd, you can optionally wrap the daemon in a user service for automatic restarts, but the daemon itself doesn't need it.

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

### Alternative: a systemd timer on the host

The daemon exists for the case where you only have access inside the container, with no way to schedule anything on the host. If you do have systemd on the host, you don't need `abs` at all: a timer can reach into the container directly with `docker exec` (or `docker compose exec`), without a daemon running anywhere.

```ini
# ~/.config/systemd/user/abs.service
[Unit]
Description=Ping Claude Code inside a container

[Service]
Type=oneshot
ExecStart=docker exec <container-name> claude --print "."
```

Use `docker compose exec <service-name> claude --print "."` instead if you're running through Compose.

```ini
# ~/.config/systemd/user/abs.timer
[Unit]
Description=Run abs.service every five hours

[Timer]
OnCalendar=*-*-* 0/5:00:00

[Install]
WantedBy=timers.target
```

```bash
systemctl --user daemon-reload
systemctl --user enable --now abs.timer
```

Check on it with `systemctl --user list-timers abs.timer` and `journalctl --user -u abs.service`.

### Configuration

| Variable       | Default | Description                                      |
| -------------- | ------- | ------------------------------------------------ |
| `ABS_INTERVAL` | `5h`    | How often to ping, passed directly to `sleep`.   |

### Requirements

The `claude` CLI, installed and authenticated. `abs` runs `claude --print "."` on a timer and doesn't handle login.

<hr/>

<p align="center">Copyright (c) 2026, @jeremysball, MIT License</p>
