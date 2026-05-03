#!/usr/bin/env node

// Install extensions from ide/<editor>/extensions.json.
// Usage: node scripts/install-extensions.js [--vscode] [--codium] [--kiro]

import { execSync } from "node:child_process"
import { readFileSync } from "node:fs"
import { dirname, resolve } from "node:path"
import { createInterface } from "node:readline/promises"
import { fileURLToPath } from "node:url"

const __dirname = dirname(fileURLToPath(import.meta.url))

const EDITORS = {
  vscode: {
    flag: "--vscode",
    cmd: "code --install-extension",
    dir: "vscode",
  },
  codium: {
    flag: "--codium",
    cmd: "codium --install-extension",
    dir: "vscode",
  },
  kiro: { flag: "--kiro", cmd: "kiro --install-extension", dir: "kiro" },
}

function extensionsPath(editor) {
  const { dir } = EDITORS[editor]
  return resolve(__dirname, `../ide/${dir}/extensions.json`)
}

async function promptEditor() {
  const rl = createInterface({ input: process.stdin, output: process.stdout })
  try {
    const answer = await rl.question(
      "Which editor? (1) vscode  (2) codium  (3) kiro: ",
    )
    const choice = answer.trim()
    if (choice === "1") return ["vscode"]
    if (choice === "2") return ["codium"]
    if (choice === "3") return ["kiro"]
    console.error("Invalid choice.")
    process.exit(1)
  } finally {
    rl.close()
  }
}

function parseArgs() {
  return Object.entries(EDITORS)
    .filter(([, { flag }]) => process.argv.includes(flag))
    .map(([name]) => name)
}

function installExtensions(editor) {
  const { cmd } = EDITORS[editor]
  const filePath = extensionsPath(editor)

  let extensions
  try {
    const json = JSON.parse(readFileSync(filePath, "utf-8"))
    extensions = json.recommendations ?? []
  } catch (err) {
    console.error(`  ✗ Failed to read ${filePath}: ${err.message}`)
    return
  }

  console.log(`\n[${editor}] Installing ${extensions.length} extensions...`)

  for (const ext of extensions) {
    try {
      execSync(`${cmd} ${ext}`, { stdio: "pipe" })
      console.log(`  ✓ ${ext}`)
    } catch {
      console.error(`  ✗ ${ext}`)
    }
  }
}

async function main() {
  let editors = parseArgs()
  if (editors.length === 0) {
    editors = await promptEditor()
  }

  for (const editor of editors) {
    installExtensions(editor)
  }

  console.log("\nDone.")
}

main()
