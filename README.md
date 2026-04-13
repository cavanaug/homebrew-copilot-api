# homebrew-copilot-api

Homebrew tap for [copilot-api](https://github.com/caozhiyuan/copilot-api) — turns GitHub Copilot into an OpenAI/Anthropic-compatible API server.

> **Disclaimer:** copilot-api is a reverse-engineered project that proxies GitHub Copilot's internal APIs. It is not affiliated with or endorsed by GitHub or Microsoft. Use it at your own risk and in accordance with GitHub's terms of service.

---

## Install

```bash
brew tap cavanaug/copilot-api
brew install copilot-api
```

> **Note:** [Bun](https://bun.sh) is required and is installed automatically as a dependency.

---

## Authentication

There are two ways to authenticate with GitHub Copilot:

### Interactive (device flow)

```bash
copilot-api auth
```

Follow the prompts to log in via your browser. Credentials are cached locally.

### Token-based

Pass your GitHub token directly at startup:

```bash
copilot-api start --github-token <token>
```

Or set it persistently in the environment file (see [Systemd Service](#systemd-service-linux) below):

```bash
echo 'GH_TOKEN=<token>' >> ~/.config/copilot-api/env
```

---

## Usage

```bash
copilot-api start [options]
```

| Flag | Short | Default | Description |
|------|-------|---------|-------------|
| `--port` | `-p` | `4141` | Port to listen on |
| `--verbose` | `-v` | — | Enable verbose logging |
| `--account-type` | `-a` | `individual` | Copilot account type: `individual`, `business`, or `enterprise` |
| `--github-token` | `-g` | — | GitHub personal access token |
| `--rate-limit` | `-r` | — | Enable rate limiting |
| `--wait` | `-w` | — | Wait for Copilot token before accepting requests |
| `--claude-code` | `-c` | — | Enable Claude Code compatibility mode |

The server exposes an OpenAI-compatible `/v1/chat/completions` endpoint on the configured port.

---

## Systemd Service (Linux)

A ready-to-use systemd user service file is installed with the formula.

### 1. Copy the service file

```bash
cp $(brew --prefix)/share/copilot-api/copilot-api.service ~/.config/systemd/user/
```

### 2. Create the environment file

```bash
mkdir -p ~/.config/copilot-api
touch ~/.config/copilot-api/env
```

### 3. (Optional) Add configuration

```bash
# ~/.config/copilot-api/env
GH_TOKEN=your_github_token
# COPILOT_API_OAUTH_APP=your_app_id   # override default OAuth app
```

> The `EnvironmentFile` directive uses a leading `-` in the unit file, so the service starts normally even if the env file does not exist.

### 4. Enable and start the service

```bash
systemctl --user daemon-reload
systemctl --user enable --now copilot-api
```

To check status or view logs:

```bash
systemctl --user status copilot-api
journalctl --user -u copilot-api -f
```

---

## Updating

### Standard update (recommended)

```bash
brew update && brew upgrade copilot-api
```

### From the tap repo (maintainers)

`update.sh` fetches the latest GitHub release, computes its SHA256, and updates the formula idempotently. Run it from the tap repository root:

```bash
cd $(brew --repo cavanaug/copilot-api)
./update.sh
brew reinstall copilot-api
```

---

## License

MIT — see [LICENSE](LICENSE).
