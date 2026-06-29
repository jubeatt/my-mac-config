#!/usr/bin/env node

// Create symlinks from config files in this repo to their expected locations.
// Links every config; entries whose target directory does not exist are skipped.
// Usage: node scripts/link-configs.js

import {
  existsSync,
  lstatSync,
  readdirSync,
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
  codium: {
    source: resolve(__dirname, "../ide/vscode"),
    target: `${home}/Library/Application Support/VSCodium/User`,
    files: IDE_LINK_FILES,
  },
  kiro: {
    source: resolve(__dirname, "../ide/kiro"),
    target: `${home}/Library/Application Support/Kiro/User`,
    files: IDE_LINK_FILES,
  },
  vim: {
    source: resolve(__dirname, ".."),
    target: home,
    files: [".vimrc"],
  },
  git: {
    source: resolve(__dirname, ".."),
    target: home,
    files: [".gitconfig"],
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
  cmux: {
    source: resolve(__dirname, "../terminal/cmux"),
    target: `${home}/.config/cmux`,
    files: ["cmux.json"],
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
  },
}

const CONFIG_NAMES = Object.keys(CONFIGS)

// Returns: { linked: number, failed: number, skipped: boolean }
function linkConfig(name) {
  const { source, target, files, linkAll } = CONFIGS[name]
  const result = { linked: 0, failed: 0, skipped: false }

  console.log(`\n[${name}]`)

  if (!existsSync(target)) {
    console.log(`  ⚠ skipped — target directory does not exist: ${target}`)
    result.skipped = true
    return result
  }

  const available = linkAll
    ? readdirSync(source).filter(
        (f) => !f.startsWith(".") && lstatSync(resolve(source, f)).isFile(),
      )
    : readdirSync(source).filter((f) => files.includes(f))

  for (const file of available) {
    const src = resolve(source, file)
    const dest = resolve(target, file)

    try {
      const stat = lstatSync(dest)
      if (stat) unlinkSync(dest)
    } catch {
      // dest doesn't exist, that's fine
    }

    try {
      symlinkSync(src, dest)
      console.log(`  ✓ ${file} -> ${src}`)
      result.linked++
    } catch (err) {
      console.error(`  ✗ ${file}: ${err.message}`)
      result.failed++
    }
  }

  return result
}

function main() {
  let totalLinked = 0
  let totalFailed = 0
  let totalSkipped = 0

  for (const name of CONFIG_NAMES) {
    const { linked, failed, skipped } = linkConfig(name)
    totalLinked += linked
    totalFailed += failed
    if (skipped) totalSkipped++
  }

  const parts = [`✓ ${totalLinked} linked`]
  if (totalSkipped > 0) parts.push(`⚠ ${totalSkipped} skipped`)
  if (totalFailed > 0) parts.push(`✗ ${totalFailed} failed`)
  console.log(`\n${parts.join(", ")}`)
}

main()
