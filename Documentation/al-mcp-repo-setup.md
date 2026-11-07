# AL Language MCP Server — Repository Setup

This document explains how to wire the AL Language MCP server into a repository so Claude Code can query AL symbols and diagnostics for that project.

See [al-mcp-prerequisites.md](al-mcp-prerequisites.md) first — the `al.exe` tool must be installed before this will work.

## How it works

Claude Code reads `.mcp.json` in the repository root and launches the servers listed there. The AL server accepts one or more AL project folder paths as positional arguments and a shared `.alpackages` cache path. It then starts the AL language server and exposes its capabilities as MCP tools.

## Step 1 — create `.mcp.json`

Add a `.mcp.json` file to the repository root. List every AL sub-project folder (i.e. every folder that contains an `app.json`) as a separate argument.

```json
{
  "mcpServers": {
    "al-language": {
      "command": "C:\\Users\\<YourUsername>\\.dotnet\\tools\\al.exe",
      "args": [
        "launchmcpserver",
        "C:\\<repo-root>\\Core",
        "C:\\<repo-root>\\Report Pack",
        "--packagecachepath",
        "C:\\<repo-root>\\.alpackages"
      ]
    }
  }
}
```

Replace `<YourUsername>` with your Windows username and `<repo-root>` with the absolute path to the repository.

> **Note on `al.exe` path** — .NET global tools always install to `%USERPROFILE%\.dotnet\tools\`. If you are unsure of the full path, run `(Get-Command al).Source` in PowerShell.

> **Note on paths** — `.mcp.json` is checked into git and shared with the team, but the absolute paths inside it are machine-specific. If the team uses different drive letters or user directories, each developer should keep a local override in `.mcp.json` and add `.mcp.json` to `.gitignore`, or use a shared convention (e.g. an environment variable wrapper script).

### ForNAV ReportPack example (this repo)

```json
{
  "mcpServers": {
    "al-language": {
      "command": "C:\\Users\\RenéBrummel\\.dotnet\\tools\\al.exe",
      "args": [
        "launchmcpserver",
        "X:\\SourceCode\\Cust.ForNAV.Own\\ForNav.ReportPack\\Core",
        "X:\\SourceCode\\Cust.ForNAV.Own\\ForNav.ReportPack\\Language",
        "X:\\SourceCode\\Cust.ForNAV.Own\\ForNav.ReportPack\\Service",
        "X:\\SourceCode\\Cust.ForNAV.Own\\ForNav.ReportPack\\Report Pack",
        "X:\\SourceCode\\Cust.ForNAV.Own\\ForNav.ReportPack\\ZugFerd",
        "--packagecachepath",
        "X:\\SourceCode\\Cust.ForNAV.Own\\ForNav.ReportPack\\.alpackages"
      ]
    }
  }
}
```

## Step 2 — enable the server in Claude Code settings

Claude Code requires the server to be explicitly enabled. Add it to `.claude/settings.json` in the repository:

```json
{
  "enabledMcpjsonServers": ["al-language"]
}
```

This file is safe to commit — it contains no machine-specific paths.

## Step 3 — verify

Open the repository in Claude Code and ask it to run a quick test:

```
test the al mcp server — get diagnostics for <any .al file> and search for a symbol
```

Or call the tools directly in a session:

- **`al_getpackagedependencies`** — should return the app's dependencies from `app.json`
- **`al_symbolsearch`** with `query="*"` and a `kinds` filter — should return project symbols
- **`al_getdiagnostics`** with a `projectPath` — should return compiler errors/warnings

## Available MCP tools

| Tool | Purpose |
|---|---|
| `al_getdiagnostics` | Compiler errors and warnings for a file, folder, or project |
| `al_symbolsearch` | Search tables, codeunits, pages, fields, methods across project and dependencies |
| `al_getpackagedependencies` | List dependencies from `app.json` |
| `al_downloadsymbols` | Download dependency symbols |
| `al_compile` | Compile an AL project |
| `al_build` | Full build (compile + package) |
| `al_publish` | Publish an app to a BC server |
| `al_run_tests` | Run AL test codeunits |
| `al_auth_login` / `al_auth_logout` | Authenticate against a BC environment |

## Troubleshooting

**Server does not appear in Claude Code** — check that `enabledMcpjsonServers` in `.claude/settings.json` includes `"al-language"`.

**Symbol search returns 0 results** — the `.alpackages` folder may be empty. Run AL: Download Symbols in VS Code first, then restart Claude Code.

**`al.exe` not found** — run `dotnet tool install -g microsoft.dynamics.businesscentral.development.tools` and confirm `%USERPROFILE%\.dotnet\tools` is on your `PATH`.

**Diagnostics show missing symbols from other sub-projects** — this is normal when scoping diagnostics to a single file instead of the full project. Scope to `projectPath` instead of `filePath` for accurate cross-project results.
