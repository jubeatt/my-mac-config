#!/usr/bin/env node

// Create symlinks from config files in this repo to their expected locations.
// Links every config; missing target directories are created first.
// A `files` entry is either a filename or { from, to } to link under a different name.
// Usage: node scripts/link-configs.js

import {
  chmodSync,
  existsSync,
  lstatSync,
  mkdirSync,
  readdirSync,
  statSync,
  symlinkSync,
  unlinkSync,
} from "node:fs"
import { dirname, resolve } from "node:path"
import { fileURLToPath } from "node:url"

const __dirname = dirname(fileURLToPath(import.meta.url))
const home = process.env.HOME

const IDE_LINK_FILES = ["settings.json", "keybindings.json"]

const CONFIGS = {
  vscode: {
    source: resolve(__dirname, "../ide/vscode"),
    target: `${home}/Library/Application Support/Code/User`,
    files: IDE_LINK_FILES,
  },
  nvim: {
    source: resolve(__dirname, "../ide"),
    target: `${home}/.config`,
    files: ["nvim"],
  },
  uv: {
    source: resolve(__dirname, ".."),
    target: `${home}/.config/uv`,
    files: ["uv.toml"],
  },
  git: {
    source: resolve(__dirname, ".."),
    target: home,
    files: [".gitconfig", ".gitignore_global"],
  },
  zsh: {
    source: resolve(__dirname, ".."),
    target: home,
    files: [".zshrc"],
  },
  ghostty: {
    source: resolve(__dirname, "../terminal/ghostty"),
    target: `${home}/.config/ghostty`,
    files: ["config"],
  },
  herdr: {
    source: resolve(__dirname, "../terminal/herdr"),
    target: `${home}/.config/herdr`,
    files: ["config.toml"],
  },
  claude: {
    source: resolve(__dirname, "../ai"),
    target: `${home}/.claude`,
    files: [{ from: "AGENTS.md", to: "CLAUDE.md" }],
  },
  codex: {
    source: resolve(__dirname, "../ai"),
    target: `${home}/.codex`,
    files: ["AGENTS.md"],
  },
  lazygit: {
    source: resolve(__dirname, "../terminal/lazygit"),
    target: `${home}/Library/Application Support/lazygit`,
    files: ["config.yml"],
  },
  bin: {
    source: resolve(__dirname, "../bin"),
    target: `${home}/.local/bin`,
    linkAll: true,
    executable: true,
  },
}

const CONFIG_NAMES = Object.keys(CONFIGS)

// Normalizes a `files` entry to a { from, to } pair.
const toPair = (file) =>
  typeof file === "string" ? { from: file, to: file } : file

// Returns: { linked: number, failed: number }
function linkConfig(name) {
  const { source, target, files, linkAll, executable } = CONFIGS[name]
  const result = { linked: 0, failed: 0 }

  console.log(`\n[${name}]`)

  if (!existsSync(target)) {
    mkdirSync(target, { recursive: true })
    console.log(`  + created ${target}`)
  }

  const pairs = linkAll
    ? readdirSync(source)
        .filter(
          (f) => !f.startsWith(".") && lstatSync(resolve(source, f)).isFile(),
        )
        .map(toPair)
    : files.map(toPair).filter(({ from }) => existsSync(resolve(source, from)))

  for (const { from, to } of pairs) {
    const src = resolve(source, from)
    const dest = resolve(target, to)

    try {
      const stat = lstatSync(dest)
      if (stat) unlinkSync(dest)
    } catch {
      // dest doesn't exist, that's fine
    }

    try {
      // Ensure the source is executable so the symlink is runnable too
      // (symlink permissions follow the target file).
      if (executable) {
        const mode = statSync(src).mode
        chmodSync(src, mode | 0o111)
      }
      symlinkSync(src, dest)
      console.log(`  ✓ ${to} -> ${src}`)
      result.linked++
    } catch (err) {
      console.error(`  ✗ ${to}: ${err.message}`)
      result.failed++
    }
  }

  return result
}

function main() {
  let totalLinked = 0
  let totalFailed = 0

  for (const name of CONFIG_NAMES) {
    const { linked, failed } = linkConfig(name)
    totalLinked += linked
    totalFailed += failed
  }

  const parts = [`✓ ${totalLinked} linked`]
  if (totalFailed > 0) parts.push(`✗ ${totalFailed} failed`)
  console.log(`\n${parts.join(", ")}`)
}

main()
