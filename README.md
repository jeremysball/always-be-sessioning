<p align="center">
  Always Be Sessioning
</p>
<hr/>

The problem: When using Claude Code there are two quotas: the five hour session and the week.
The five hour session doesn't start until you send your first request; therefore, you can be
left with a situation where if you had sent a single message four hours ago you could have a refresh in one hour,
but instead the timer just started ticking down.

The solution: A small daemon that runs in the background and periodically calls Claude Code to trigger sessions. Just a single
invocation every five hours. Simple.

### Usage

```bash
```

Copyright (c) 2026, [@jeremysball], MIT License
