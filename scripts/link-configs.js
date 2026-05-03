#!/usr/bin/env node

// Create symlinks from config files in this repo to their expected locations.
// Usage: node scripts/link-configs.js [--all] [--vscode] [--codium] [--kiro] [--kiro-cli] [--vim] [--zsh] [--ghostty] [--cmux] [--lazygit]

import {
  existsSync,
  lstatSync,
  readdirSync,
  symlinkSync,
  unlinkSync,
} from "node:fs"
import { dirname, resolve } from "node:path"
import { createInterface } from "node:readline/promises"
import { fileURLToPath } from "node:url"

const __dirname = dirname(fileURLToPath(import.meta.url))
const home = process.env.HOME

const IDE_LINK_FILES = ["settings.json", "keybindings.json"]
const KIRO_CLI_DIRS = ["agents", "skills", "steering", "hooks"]

const CONFIGS = {
  vscode: {
    flag: "--vscode",
    source: resolve(__dirname, "../ide/vscode"),
    target: `${home}/Library/Application Support/Code/User`,
    files: IDE_LINK_FILES,
  },
  codium: {
    flag: "--codium",
    source: resolve(__dirname, "../ide/vscode"),
    target: `${home}/Library/Application Support/VSCodium/User`,
    files: IDE_LINK_FILES,
  },
  kiro: {
    flag: "--kiro",
    source: resolve(__dirname, "../ide/kiro"),
    target: `${home}/Library/Application Support/Kiro/User`,
    files: IDE_LINK_FILES,
  },
  vim: {
    flag: "--vim",
    source: resolve(__dirname, ".."),
    target: home,
    files: [".vimrc"],
  },
  git: {
    flag: "--git",
    source: resolve(__dirname, ".."),
    target: home,
    files: [".gitconfig"],
  },
  zsh: {
    flag: "--zsh",
    source: resolve(__dirname, ".."),
    target: home,
    files: [".zshrc"],
  },
  "kiro-cli": {
    flag: "--kiro-cli",
    source: resolve(__dirname, "../ai/.kiro"),
    target: `${home}/.kiro`,
    files: KIRO_CLI_DIRS,
  },
  ghostty: {
    flag: "--ghostty",
    source: resolve(__dirname, "../terminal/ghostty"),
    target: `${home}/.config/ghostty`,
    files: ["config"],
  },
  cmux: {
    flag: "--cmux",
    source: resolve(__dirname, "../terminal/cmux"),
    target: `${home}/.config/cmux`,
    files: ["cmux.json", "settings.json"],
  },
  lazygit: {
    flag: "--lazygit",
    source: resolve(__dirname, "../terminal/lazygit"),
    target: `${home}/Library/Application Support/lazygit`,
    files: ["config.yml"],
  },
}

const CONFIG_NAMES = Object.keys(CONFIGS)

async function promptConfig() {
  const rl = createInterface({ input: process.stdin, output: process.stdout })
  try {
    const choices = CONFIG_NAMES.map((name, i) => `(${i + 1}) ${name}`).join(
      "  ",
    )
    const answer = await rl.question(`Which config? ${choices}  (a) all: `)
    const choice = answer.trim().toLowerCase()
    if (choice === "a") return CONFIG_NAMES
    const index = Number.parseInt(choice, 10) - 1
    if (index >= 0 && index < CONFIG_NAMES.length) return [CONFIG_NAMES[index]]
    console.error("Invalid choice.")
    process.exit(1)
  } finally {
    rl.close()
  }
}

function parseArgs() {
  if (process.argv.includes("--all")) return CONFIG_NAMES
  return Object.entries(CONFIGS)
    .filter(([, { flag }]) => process.argv.includes(flag))
    .map(([name]) => name)
}

// Returns: { linked: number, failed: number, skipped: boolean }
function linkConfig(name) {
  const { source, target, files } = CONFIGS[name]
  const result = { linked: 0, failed: 0, skipped: false }

  console.log(`\n[${name}]`)

  if (!existsSync(target)) {
    console.log(`  ⚠ skipped — target directory does not exist: ${target}`)
    result.skipped = true
    return result
  }

  const available = readdirSync(source).filter((f) => files.includes(f))

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

async function main() {
  let configs = parseArgs()
  if (configs.length === 0) {
    configs = await promptConfig()
  }

  let totalLinked = 0
  let totalFailed = 0
  let totalSkipped = 0

  for (const name of configs) {
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
