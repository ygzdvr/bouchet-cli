# bouchet-cli

CLI tools and aliases for Yale HPC (Bouchet, Grace, McCleary).

| Alias | What it does |
|---|---|
| `g` | `git` |
| `cl` | Claude Code, skip permissions |
| `cx` | Codex CLI, `--yolo` |
| `clr` | Claude Code, skip permissions, resume last session |
| `cxr` | Codex CLI, `--yolo`, resume last session |
| `lm` / `limits` | Claude and Codex usage bars (session + week) |
| `status` / `st` | Slurm session, idle GPUs, your jobs, monthly allocation, storage |

No extra Python packages. Needs `python3` (already on YCRC clusters).

## Install (one line)

```bash
curl -fsSL https://raw.githubusercontent.com/ygzdvr/bouchet-cli/main/install.sh | bash
source ~/.bashrc
```

Then:

```bash
lm          # or: limits
status      # or: st
cl          # Claude
cx          # Codex
```

`~/.local/bin` is already on `PATH` for most Yale accounts. If `lm` or `status` is not found:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### From a clone

```bash
git clone https://github.com/ygzdvr/bouchet-cli.git
cd bouchet-cli
./install.sh
```

## `lm` / `limits` — AI usage

Requires at least one of these on `PATH`:

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`claude`)
- [Codex CLI](https://github.com/openai/codex) (`codex`)

Logged-out or missing tools are skipped. Token counts and email are never printed.

## `status` / `st` — cluster dashboard

Meant for **YCRC Slurm** (Bouchet / Grace / McCleary). Needs:

- `squeue`, `sinfo`, `scontrol`, `sshare`, `sacct` (standard Slurm)
- `getquota` for STORAGE (YCRC module environment; section is omitted if missing)
- `$SCRATCH` or `~/scratch_*/$USER` for scratch usage

GPU rows cover the usual Yale types (H100, H200, B200, RTX PRO 6000, L40S, A40). Partitions shown: `day`, `devel`, `week`, `mpi`.

## Uninstall

```bash
rm -f ~/.local/bin/lm ~/.local/bin/status
# then delete the "# --- bouchet-cli aliases ---" block from ~/.aliases.sh or ~/.bashrc
```

## License

MIT
