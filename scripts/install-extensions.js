#!/usr/bin/env node

// Install VS Code extensions from ide/vscode/extensions.json.
// Skips extensions that are already installed.
// Usage: node scripts/install-extensions.js

import { execSync } from "node:child_process"
import { readFileSync } from "node:fs"
import { dirname, resolve } from "node:path"
import { fileURLToPath } from "node:url"

const __dirname = dirname(fileURLToPath(import.meta.url))
const EXTENSIONS_PATH = resolve(__dirname, "../ide/vscode/extensions.json")

function readExtensions() {
  try {
    const json = JSON.parse(readFileSync(EXTENSIONS_PATH, "utf-8"))
    return json.recommendations ?? []
  } catch (err) {
    console.error(`✗ Failed to read ${EXTENSIONS_PATH}: ${err.message}`)
    process.exit(1)
  }
}

function getInstalledExtensions() {
  const ids = execSync("code --list-extensions", { encoding: "utf-8" })
    .trim()
    .split("\n")
    .map((id) => id.toLowerCase())
    .filter(Boolean)
  return new Set(ids)
}

function main() {
  const installed = getInstalledExtensions()
  const missing = readExtensions().filter(
    (ext) => !installed.has(ext.toLowerCase()),
  )

  if (missing.length === 0) {
    console.log("✓ All extensions already installed")
    return
  }

  console.log(`Installing ${missing.length} extensions...`)

  for (const ext of missing) {
    try {
      execSync(`code --install-extension ${ext}`, { stdio: "pipe" })
      console.log(`  ✓ ${ext}`)
    } catch {
      console.error(`  ✗ ${ext}`)
    }
  }

  console.log("\nDone.")
}

main()
