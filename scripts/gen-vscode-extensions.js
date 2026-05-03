#!/usr/bin/env node

// Sync installed extensions to ide/<editor>/extensions.json.
// Usage: node scripts/gen-vscode-extensions.js [--vscode] [--codium] [--kiro] [--dryrun]

import { execSync } from "node:child_process"
import { readFileSync, writeFileSync } from "node:fs"
import { dirname, resolve } from "node:path"
import { createInterface } from "node:readline/promises"
import { fileURLToPath } from "node:url"

const __dirname = dirname(fileURLToPath(import.meta.url))

const EDITORS = {
  vscode: { flag: "--vscode", cmd: "code --list-extensions", dir: "vscode" },
  codium: {
    flag: "--codium",
    cmd: "codium --list-extensions",
    dir: "vscode",
  },
  kiro: { flag: "--kiro", cmd: "kiro --list-extensions", dir: "kiro" },
}

function extensionsPath(editor) {
  const { dir } = EDITORS[editor]
  return resolve(__dirname, `../ide/${dir}/extensions.json`)
}

function getInstalledExtensions(cmd) {
  return execSync(cmd, { encoding: "utf-8" })
    .trim()
    .split("\n")
    .map((id) => id.toLowerCase())
    .filter(Boolean)
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

function syncEditor(editor) {
  const { cmd } = EDITORS[editor]
  const filePath = extensionsPath(editor)

  console.log(`Fetching extensions from ${editor}...`)
  const extensions = getInstalledExtensions(cmd)
  console.log(`  Found ${extensions.length} extensions.`)

  // Read existing file
  let existing = []
  try {
    const json = JSON.parse(readFileSync(filePath, "utf-8"))
    existing = (json.recommendations ?? []).map((id) => id.toLowerCase())
  } catch {
    // File doesn't exist yet
  }

  const result = [...new Set(extensions)].sort()
  const added = result.filter((ext) => !existing.includes(ext))
  const removed = existing.filter((ext) => !result.includes(ext))

  if (added.length > 0) {
    console.log(`\n  Added (${added.length}):`)
    for (const ext of added) console.log(`    + ${ext}`)
  }
  if (removed.length > 0) {
    console.log(`\n  Removed (${removed.length}):`)
    for (const ext of removed) console.log(`    - ${ext}`)
  }

  const dryrun = process.argv.includes("--dryrun")
  if (dryrun) {
    console.log(`\n  [dryrun] ${filePath} not written.`)
  } else {
    const output = JSON.stringify({ recommendations: result }, null, "\t")
    writeFileSync(filePath, `${output}\n`)
    console.log(`\n  Written to ${filePath} (${result.length} extensions).`)
  }
}

async function main() {
  let editors = parseArgs()
  if (editors.length === 0) {
    editors = await promptEditor()
  }

  for (const editor of editors) {
    syncEditor(editor)
    console.log()
  }
}

main()
