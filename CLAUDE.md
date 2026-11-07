# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

**Multiple Report Layout Selector** (Red and Bundle): a Business Central AL extension that picks a report layout at print/email time based on the record being printed (customer, vendor, dimension, item, etc.), on Report Selection Usage, or by prompting the user. It works with any report (Microsoft standard, ForNAV, or custom) and has no third-party dependencies; it requires BC 28 or later. End-user docs: https://multilayout.redandbundle.com/

## Project layout (three app.json files)

| Folder | App | ID range | Purpose |
|---|---|---|---|
| `Red.MultipleLayouts/` | Multiple Report Layout Selector | 11310862–11310912 | The shipped product (AppSource, affix `Red`) |
| `Red.MultipleLayouts.Test/` | Red.MultipleLayouts.Test | 80500–80550 | Test app; product exposes internals to it via `internalsVisibleTo` |
| repo root `app.json` | Red.MultipleLayouts.Dev | both ranges | Dev workspace that compiles product + tests together as one app for local publish/debug |

- Keep the `version` and `platform`/`application` (currently BC 28 / runtime 17.0) in sync across all three `app.json` files. The test app's dependency on the product version must match the product version.
- Do not add a dependency on ForNAV (or other third-party apps); the product depends only on Microsoft apps. The only ForNAV-aware code is the `<>ForNAV BC preview*` filter on Tenant Report Layouts, which is a harmless string filter.
- New product objects go in the 11310862–11310912 range and must use the `Red` prefix (AppSourceCop `mandatoryAffixes`). Test objects go in 80500–80550.

## Build, test, validate

- Build/package via the AL Language MCP server (`al_build` / `al_compile`, `al_getdiagnostics` scoped to a `projectPath`), or the `red-al-tools:red-build-al` skill. The server is configured in `.mcp.json` (projects `Red.MultipleLayouts` and `Red.MultipleLayouts.Test`, shared cache `.alpackages`) and enabled in `.claude/settings.json`; setup is described in `Documentation/al-mcp-prerequisites.md` and `Documentation/al-mcp-repo-setup.md`.
- Built `.app` files for a release go in `_Build/`; older releases are moved to `_Build Archive/`. `.app` files are gitignored.
- Code signing: `Scripts/Codesign.ps1` signs every `.app` in `_Build/` with Azure Artifact Signing (account `red-codesign-we`, settings in `Scripts/ArtifactSigning.json`) via Windows SDK signtool x64 + the Artifact Signing dlib (auto-downloaded to `%LOCALAPPDATA%\RedAndBundle\ArtifactSigning`). Run `az login` first; needs NavSip.dll registered for x64.
- Code analysis: CodeCop with `_BC.ruleset.json` (disables AA0247, AA0214, AA0139, AA0210, AA0072).
- Tests: the test app's install codeunit (`Red.MultipleLayouts.Test/Install Objects/RedMultiLayoutInstall.Codeunit.al`) creates test suite `REDMULTI` covering codeunits 80500..80550. In a container: `Run-TestsInNavContainer -containerName <name> -credential $cred -detailed -testSuite 'REDMULTI'` (see `Scripts/DockerRunTests.ps1`). To run a single test codeunit use `al_run_tests` or `Run-TestsInBcContainer -testCodeunit <id> [-testFunction <name>]`.
- AppSource validation: `Scripts/RunALValidation.ps1` (BcContainerHelper `Run-AlValidation` against the previous release in `_Build Archive`, countries nl/de/dk/us). Update the `$app` / `$prev` paths when releasing.
- Container setup: `Scripts/DockerSetupDev.ps1` creates a BC 28 container with the test toolkit (no ForNAV apps needed).
- Building the test app needs the product's symbols: copy the built product `.app` into `.alpackages` (and restart the MCP server if `al_build` still reports product objects missing).
- Translations: languages are da-DK, de-DE, en-US, nl-NL in `Red.MultipleLayouts/Translations/`. Use the `fornav-al-tools:fornav-translate` skill (or `Scripts/Translate.ps1`, ForNAV cmdlet Excel round-trip).
- Release order (`red-al-tools:red-release-al`): docs → translations → build. README checklist: translation, permission sets, documentation, release notes, automated tests, functional tests, usage scenario.

## Architecture

**Entry point** — `Objects/Events/RedReportSelectionsEvents.Codeunit.al` subscribes to `Report Selections` `OnBeforePrintDocument` and `OnBeforeSaveReportAsPDF` (email/save). For each call it:
1. `Red Layout Recorder` (SingleInstance): if "recording" mode is on and in GUI, it inserts a `Red Report Layout Selection` row for the report+table instead of printing (sets IsHandled).
2. `Red Layout Selection.MoveToTenantLayout(ReportID)`: lazily migrates legacy rows for that report (see below).
3. `Red Report Layout Selection` codeunit resolves the layout and either sets it (PDF/email path) or runs the report itself with it (print path; IsHandled only if a layout was used).

**Layout resolution** (`Objects/Tenant Layouts/RedReportLayoutSelection.Codeunit.al`), first match wins:
1. Rows in table `Red Report Layout Selection` for the report + the printed record's table with `Field No. > 0`, where the record matches the row's field filter (`MatchRecordVariable` applies `Value` as a filter on a copy of the RecordRef, so values are filter expressions). Usage must equal the actual usage or `RedBlank` (enum extension value meaning "any usage").
2. A `Default` row for the report (specific usage first, then `RedBlank`); an empty-layout row means "built-in default".
3. Otherwise all Tenant Report Layouts for the report (excluding ForNAV preview and `*email*` layouts), plus built-in layouts from `Report Layout List` if no design-time selection exists.

With several candidates the user picks one (page `Red Report Layouts`, or `StrMenu` if inside a write transaction since RunModal isn't allowed there); without GUI the first is taken. The choice is applied through `Design-time Report Selection.SetSelectedLayout` (by name, plus App ID for extension-provided layouts) and cleared after the report runs.

**Legacy / obsolete model** — `Objects/Obsolete/` holds the pre-3.0 `Red Layout Selection` table (keyed on Custom Report Layout codes). It's kept only for upgrade: rows are converted into `Red Report Layout Selection` (Tenant Report Layout based) on upgrade (`Red Layout Upgrade`) and lazily per report at print time, then deleted. Public procedures there are `[Obsolete]` stubs that must keep their signatures for compatibility; don't add new logic there. Code touching them is wrapped in `#pragma warning disable AL0432`.

**Commit handling** — `Red Layout Setup."Commit on Post"` makes the Sales/Purch "Post + Print" subscribers `Commit()` before printing, so the layout picker page can open. Tests use `Red Layout Suppress Commit` (manual subscriber) to exercise the write-transaction path.

**Other pieces** — `Backup/` exports/imports layout selection rows; `Red Layout Value Selection` provides lookups (customer, vendor, dimension, contact, payment terms, item, bank account, responsibility center) for the `Value` field; `Telemetry/` emits daily telemetry; permission sets live in `Red.MultipleLayouts/Permission/` and must be updated when tables are added.
