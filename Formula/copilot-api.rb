# typed: true
# frozen_string_literal: true

class CopilotApi < Formula
  desc "Turn GitHub Copilot into an OpenAI/Anthropic-compatible API server"
  homepage "https://github.com/caozhiyuan/copilot-api"
  url "https://github.com/caozhiyuan/copilot-api/archive/refs/tags/v1.5.8.tar.gz"
  sha256 "7cc9a471a217e096c27bf9e6686f7c4509a22f64103827bd9f71b05d42a41fb9"
  license "MIT"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "oven-sh/bun/bun"

  def install
    system "bun", "install", "--frozen-lockfile"
    system "bun", "run", "build"

    # tsdown code-splits but does not bundle node_modules — runtime needs them.
    # pages/ must be a sibling of dist/ under libexec — server.ts resolves
    # pages/index.html via new URL("../pages/index.html", import.meta.url)
    libexec.install "dist", "pages", "node_modules"

    (bin/"copilot-api").write <<~EOS
      #!/bin/bash
      exec "#{Formula["oven-sh/bun/bun"].opt_bin}/bun" "#{libexec}/dist/main.js" "$@"
    EOS

    (share/"copilot-api").mkpath
    (share/"copilot-api/copilot-api.service").write <<~EOS
      [Unit]
      Description=copilot-api — GitHub Copilot OpenAI/Anthropic-compatible proxy
      After=network-online.target
      Wants=network-online.target

      [Service]
      Type=simple
      EnvironmentFile=-%h/.config/copilot-api/env
      ExecStart=#{bin}/copilot-api start
      Restart=on-failure
      RestartSec=5

      [Install]
      WantedBy=default.target
    EOS
  end

  test do
    assert_match "copilot-api", shell_output("#{bin}/copilot-api --help 2>&1")
  end
end
