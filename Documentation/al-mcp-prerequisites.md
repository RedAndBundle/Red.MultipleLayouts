# AL Language MCP Server — Prerequisites

This document describes what needs to be installed on a developer machine before the AL Language MCP server can run inside Claude Code.

## What it is

The AL Language MCP server exposes the AL compiler's language intelligence (symbol search, diagnostics, build, publish, test runner) as MCP tools to Claude Code. This lets Claude Code query and reason about AL code without leaving the conversation.

## Required: .NET SDK

The MCP server binary is a .NET global tool, so the .NET SDK must be installed first.

- Download from: https://dot.net
- Version: .NET 8 or later

Verify after install:

```powershell
dotnet --version
```

## Required: AL Language MCP tool

Install the Microsoft Business Central AL development tool as a .NET global tool:

```powershell
dotnet tool install -g microsoft.dynamics.businesscentral.development.tools
```

This installs `al.exe` into `%USERPROFILE%\.dotnet\tools\`. Make sure that directory is on your `PATH` (the SDK installer adds it automatically).

Verify after install:

```powershell
al --version
```

### Updating the tool

```powershell
dotnet tool update -g microsoft.dynamics.businesscentral.development.tools
```

## Required: AL symbols (`.alpackages`)

The MCP server resolves symbols against the compiled dependency packages. The repository must already have a populated `.alpackages` folder before the server will return useful diagnostics or symbol search results.

Run the normal BC symbol download step in VS Code (**AL: Download Symbols**) or via the build pipeline before starting Claude Code.

## Optional: Claude Code

Claude Code is required to consume the MCP server. Install it from the VS Code extension marketplace or via npm:

```powershell
npm install -g @anthropic-ai/claude-code
```
