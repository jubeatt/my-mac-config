#!/usr/bin/env node

// Sync installed VS Code extensions to ide/vscode/extensions.json.
// Usage: node scripts/gen-vscode-extensions.js [--dryrun]

import { execSync } from "node:child_process"
import { readFileSync, writeFileSync } from "node:fs"
import { dirname, resolve } from "node:path"
import { fileURLToPath } from "node:url"

const __dirname = dirname(fileURLToPath(import.meta.url))
const EXTENSIONS_PATH = resolve(__dirname, "../ide/vscode/extensions.json")

function getInstalledExtensions() {
  return execSync("code --list-extensions", { encoding: "utf-8" })
    .trim()
    .split("\n")
    .map((id) => id.toLowerCase())
    .filter(Boolean)
}

function readExistingExtensions() {
  try {
    const json = JSON.parse(readFileSync(EXTENSIONS_PATH, "utf-8"))
    return (json.recommendations ?? []).map((id) => id.toLowerCase())
  } catch {
    // File doesn't exist yet
    return []
  }
}

function printList(label, prefix, list) {
  if (list.length === 0) return
  console.log(`\n  ${label} (${list.length}):`)
  for (const ext of list) console.log(`    ${prefix} ${ext}`)
}

function main() {
  console.log("Fetching extensions from VS Code...")
  const result = [...new Set(getInstalledExtensions())].sort()
  console.log(`  Found ${result.length} extensions.`)

  const existing = readExistingExtensions()
  printList(
    "Added",
    "+",
    result.filter((ext) => !existing.includes(ext)),
  )
  printList(
    "Removed",
    "-",
    existing.filter((ext) => !result.includes(ext)),
  )

  if (process.argv.includes("--dryrun")) {
    console.log(`\n  [dryrun] ${EXTENSIONS_PATH} not written.`)
    return
  }

  const output = JSON.stringify({ recommendations: result }, null, "\t")
  writeFileSync(EXTENSIONS_PATH, `${output}\n`)
  console.log(
    `\n  Written to ${EXTENSIONS_PATH} (${result.length} extensions).`,
  )
}

main()
