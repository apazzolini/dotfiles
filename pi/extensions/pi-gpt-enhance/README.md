English | [简体中文](README.zh-CN.md)

# pi-gpt-enhance

Provides a focused set of Codex-compatible request enhancements for GPT models using the OpenAI Responses protocol in Pi: server-side context compaction, Responses `instructions` promotion, Fast mode, and an optional `apply_patch` custom tool. Model metadata is intentionally handled by [`pi-autofill-model-metadata`](../autofill-model-metadata) and the standalone [`pi-codex-gpt-metadata`](../codex-gpt-metadata) catalog, not by this extension.

> [!NOTE]
> This is a local copy of upstream commit `10f4ec0e5dab23e2bacdb6ec6926489855998ebc`. After server-side compaction, it waits for the agent to settle and then runs Pi's native compaction so the session gets a durable, provider-independent local summary. The upstream package instead replaced local history with a generic marker that became unusable after a response-chain reset or model change.

The extension only processes models that meet both of these conditions:

- `api` is `openai-responses`
- The model ID starts with `gpt-` or `openai/gpt-`

Other APIs, providers, and models are not modified.

## Installation

Install from npm into Pi's user configuration:

```bash
pi install npm:pi-gpt-enhance
```

Run temporarily from this repository:

```bash
pi -e ./packages/gpt-enhance
```

After startup, run:

```text
/gpt-enhance
```

This displays the current model and the status of all enhancements.

## Features and defaults

| Feature                                                     | Configuration                       | Default            |
| ----------------------------------------------------------- | ----------------------------------- | ------------------ |
| Global extension switch                                     | `enabled`                           | Enabled            |
| Automatic server-side compaction and Responses continuation | `compression`                       | Enabled            |
| Persist Responses application state at the provider         | `store`                             | Disabled           |
| Promote the first system/developer prompt to `instructions` | `promoteSystemPromptToInstructions` | Enabled            |
| Footer status bar                                           | `statusBar`                         | Enabled            |
| Server-side compaction notifications                        | `notify`                            | Enabled            |
| Codex-compatible `apply_patch`                              | `applyPatch`                        | Disabled           |
| Fast mode                                                   | `/gpt-enhance fast`                 | Disabled per model |

`applyPatch`, `promoteSystemPromptToInstructions`, `compression`, `store`, and Fast mode are independent of one another, but all are controlled by the global `enabled` switch.

## Configuration

Global configuration file:

```text
~/.pi/agent/gpt-enhance.json
```

Project configuration file:

```text
.pi/gpt-enhance.json
```

Precedence, from highest to lowest, is: environment variables, project configuration, global configuration, and built-in defaults. Project configuration only overrides fields that it defines.

Complete example:

```json
{
  "enabled": true,
  "compression": true,
  "store": false,
  "applyPatch": false,
  "promoteSystemPromptToInstructions": true,
  "thresholdRatio": 0.9,
  "notify": true,
  "statusBar": true
}
```

### Configuration fields

| Field                               | Type    | Description                                                                                                                                                                           |
| ----------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `enabled`                           | boolean | Fully enable or disable the extension                                                                                                                                                 |
| `compression`                       | boolean | Enable automatic server-side context compaction and Responses continuation; when disabled, `/gpt-enhance compact` can still be run explicitly and other enhancements remain available |
| `store`                             | boolean | Send the Responses `store` field; `false` keeps continuation client-side and is compatible with ZDR, while `true` enables `previous_response_id` continuation                          |
| `applyPatch`                        | boolean | Register the Codex-compatible `apply_patch`; only takes effect for eligible GPT models                                                                                                |
| `promoteSystemPromptToInstructions` | boolean | Move the first promotable system/developer string prompt to top-level `instructions`                                                                                                  |
| `compactThreshold`                  | number  | Directly specify the server-side compaction token threshold; takes precedence over `thresholdRatio`                                                                                   |
| `thresholdRatio`                    | number  | Calculate the compaction threshold from the model context window; defaults to `0.9`, capped at `0.95`                                                                                 |
| `notify`                            | boolean | Show TUI notifications related to server-side compaction                                                                                                                              |
| `statusBar`                         | boolean | Show server-side compaction and Fast status in the Pi footer; clears both statuses when disabled                                                                                      |

`promoteSystemPromptToInstructions` and `statusBar` can both be written directly in the JSON configuration file. Environment variables are only used as overrides:

| Configuration field                 | Environment variable                                   |
| ----------------------------------- | ------------------------------------------------------ |
| `enabled`                           | `PI_GPT_ENHANCE_ENABLED`                               |
| `compression`                       | `PI_GPT_ENHANCE_COMPRESSION`                           |
| `store`                             | `PI_GPT_ENHANCE_STORE`                                 |
| `applyPatch`                        | `PI_GPT_ENHANCE_APPLY_PATCH`                           |
| `promoteSystemPromptToInstructions` | `PI_GPT_ENHANCE_PROMOTE_SYSTEM_PROMPT_TO_INSTRUCTIONS` |
| `compactThreshold`                  | `PI_GPT_ENHANCE_COMPACT_THRESHOLD`                     |
| `thresholdRatio`                    | `PI_GPT_ENHANCE_THRESHOLD_RATIO`                       |
| `notify`                            | `PI_GPT_ENHANCE_NOTIFY`                                |
| `statusBar`                         | `PI_GPT_ENHANCE_STATUS_BAR`                            |

Boolean environment variables accept `true/false`, `1/0`, `yes/no`, and `on/off`.

## Commands

| Command                | Action                                                                           |
| ---------------------- | -------------------------------------------------------------------------------- |
| `/gpt-enhance`         | Alias for `/gpt-enhance status`                                                  |
| `/gpt-enhance status`  | Show the current model and the status of all enhancements                        |
| `/gpt-enhance fast`    | Toggle Fast mode for the current provider/API/model/base URL                     |
| `/gpt-enhance update`  | Clear the current model's capability cache so the next request probes again      |
| `/gpt-enhance compact` | Manually call the provider's `POST /responses/compact` while the session is idle |

Enter a space after `/gpt-enhance` to get subcommand completion with descriptions; continuing to type a prefix filters the candidates.

The status command displays an aligned panel using the current Pi theme, for example:

```text
gpt-enhance
  model           misaka-responses/gpt-5.6-sol
  server compact  not probed
  fast mode       off
  instructions    on
  apply_patch     active
  status bar      on
```

## Footer status bar

`statusBar` is enabled by default. The extension uses Pi's `ctx.ui.setStatus()` and does not replace the default footer:

| Display       | Meaning                                                                                             |
| ------------- | --------------------------------------------------------------------------------------------------- |
| `COMPACT:?`   | Server-side compaction capability not probed                                                        |
| `COMPACT:ON`  | The provider has confirmed server-side compaction support                                           |
| `COMPACT:OFF` | Server-side compaction is disabled in configuration, or the provider explicitly does not support it |
| `FAST`        | Fast mode is enabled for the current model                                                          |

Pi sorts statuses by status key, so when Fast is enabled the display is usually:

```text
COMPACT:ON FAST
```

When the current model does not pass gating, or when `statusBar` is `false`, the extension clears the `gpt-enhance.compression` and `gpt-enhance.fast` footer statuses. The `/gpt-enhance status` command remains available and displays `status bar off`.

Custom footers can preserve these statuses by continuing to read `footerData.getExtensionStatuses()`.

> [!TIP]
> We are looking for a polished Pi status bar and a one-click compatibility path for displaying `gpt-enhance` statuses in third-party footers. If you maintain or recommend a suitable status bar, please [open an issue](https://github.com/peach0x33a/pi-extensions/issues).

## Request processing order

For eligible models, every request actually sent to the provider is processed in this order:

1. Move the first promotable system/developer string prompt to `instructions`
2. Apply Fast mode's `service_tier: "priority"`
3. Apply server-side compaction or Responses continuation
4. Call the final provider `onPayload` hook

The final hook has the last word for the initial request, fallback, and continuation retries. Only returning `undefined` means that the current payload is retained; all other return values, including `null`, are treated as valid replacements.

## Server-side compaction

Normal Responses requests are still sent by Pi's built-in implementation. The extension only adds the behavior required by [OpenAI Compaction](https://developers.openai.com/api/docs/guides/compaction) at the request boundary:

1. The first eligible request adds `context_management` and an explicit `store` value; the compaction threshold defaults to 90% of the context window.
2. With the default `store: false`, the extension captures the compacted window, including its encrypted compaction item, persists it in a non-context Pi session entry, and replaces superseded input with that window on later requests.
3. With `store: true`, subsequent requests use `previous_response_id` and incremental input when available. If the provider rejects continuation, the request retries with complete local input.
4. Pi's native compaction remains active. When server compaction is detected, the extension waits for the current agent run and queued follow-ups to settle, then triggers native compaction to write a readable local summary.
5. When the provider rejects enhancement parameters or a recoverable network error occurs, the extension preserves its internal state and retries with an unenhanced payload.
6. Compaction state is cleared or restored when the model, session, or branch changes to prevent cross-provider contamination; `error` and `aborted` responses are skipped when restoring server-stored chains.

When the server actually returns `compaction` or `compaction_summary`, the extension shows one notification for that item. Once the agent settles, it triggers a normal Pi compaction instead of replacing local history with a generic server-compaction marker. Deferring until `agent_settled` avoids aborting an active tool loop.

> [!WARNING]
> Server-side compaction is still experimental and currently has known issues. Do not rely on it as the only protection against context overflow. Keep Pi's native local-compaction fallback available, and please report reproducible failures in [Issues](https://github.com/peach0x33a/pi-extensions/issues).

By default, server-side compaction sends `store: false`, so Responses application state remains client-managed and the flow is compatible with OpenAI ZDR. OpenAI may still retain abuse-monitoring logs unless the organization has an applicable data-control agreement. Setting `store: true` opts into provider-side Responses application-state retention; proxy retention behavior depends on the provider.

### Manual compaction

`/gpt-enhance compact` only runs while the session is idle and the model is eligible. It:

- Uses Pi's current valid session input in `store: false` mode
- Prefers the existing Responses `responseId` in `store: true` mode and retries with current session input when continuation is rejected
- Respects the most recent Pi compaction boundary and does not resend already-compacted history
- Uses the same `instructions` promotion logic as normal requests

A successful command does not create a local `[compaction]` summary entry in Pi. In `store: false` mode it persists the compacted window in a non-context extension state entry so later requests can continue statelessly. On failure, it only displays the error; it does not implicitly perform Pi local compaction or corrupt the current compaction state.

`/gpt-enhance update` only clears the capability cache. It does not send a model request or trigger compaction.

## Fast mode

`/gpt-enhance fast` stores preferences by this model identity:

```text
provider + api + model id + baseUrl
```

When enabled, the final OpenAI Responses request carries:

```json
{
  "service_tier": "priority"
}
```

Fast mode is independent of `compression`. When Fast is disabled, the extension does not remove a `service_tier` already set by the caller.

Preferences are stored in:

```text
~/.pi/agent/gpt-enhance-preferences.json
```

Writes use an inter-process lock and an atomic rename. A missing or invalid file is treated as Fast being disabled. Tests can use `PI_GPT_ENHANCE_PREFERENCES_FILE` to specify an isolated path.

If a third-party provider omits `service_tier` from its response, Pi may be unable to calculate the priority multiplier; the request will still carry priority.

## `instructions` promotion

By default, the extension examines the first input item in the Responses payload:

- Its role must be `developer` or `system`
- Its content must be a non-empty string
- The top level must not already contain non-empty `instructions`

When these conditions are met, the item is removed from input and the original string is moved to top-level `instructions`. The extension does not duplicate the prompt or scan subsequent items.

The payload is left unchanged when:

- Top-level `instructions` is already non-empty
- The first item is not system/developer
- Content is a structured array or another non-string value
- `promoteSystemPromptToInstructions` is `false`

This rule applies to normal requests, manual compaction, continuation fallback, and the public `compactResponseChain()` API.

## Optional `apply_patch`

Write the following configuration to the global or project `gpt-enhance.json`:

```json
{
  "applyPatch": true
}
```

When enabled, the extension registers the Codex-compatible `apply_patch` custom tool only for eligible models. It supports:

- Add, Delete, Update, and Move
- Multi-file and multi-chunk patches
- `@@` context anchors and `*** End of File`
- Codex-style exact, trailing-whitespace, trim, and Unicode matching fallbacks
- A complete deterministic preflight before writing
- Stable multi-path locking under Pi's file mutation queue

Relative paths are resolved from the current request's `ctx.cwd`. When another extension provides a tool with the same name, the external tool always takes precedence; this extension does not override, disable, or manage it. When the model changes or another extension rewrites the active tools, this extension manages only the tool instance it registered.

This feature implements file patches only. It does not include the Codex runtime's shell, `exec_command`, PTY, sandbox, approval, MCP, remote execution, or progress protocols. The tool uses the current Pi process's file permissions.

## Model metadata is provided separately

`pi-gpt-enhance` does **not** register, fill, or own model metadata. Metadata support is deliberately split into:

- [`pi-autofill-model-metadata`](../autofill-model-metadata), the Pi extension that registers and fills model metadata for custom providers
- [`pi-codex-gpt-metadata`](../codex-gpt-metadata), the standalone Codex catalog consumed by autofill; it has no Pi extension entry point and does not depend on `pi-gpt-enhance`

Configure Codex-backed metadata through autofill's `codex/<model-id>` source:

```jsonc
{
  "mapping": {
    "my-responses-provider": {
      "gpt-5.6-sol[1m]": "codex/gpt-5.6-sol[1m]",
    },
  },
}
```

The two Pi extensions have no load-order dependency: autofill registers model metadata, while gpt-enhance registers only the enhanced Responses request flow. Pi merges both provider registrations. Model fields explicitly set in `~/.pi/agent/models.json` still have the highest priority.

This extension gates request enhancements by API and model-ID prefix rather than by catalog membership, so metadata catalog updates remain independent from `pi-gpt-enhance` releases.

## Local state files

| File                                        | Contents                                                 |
| ------------------------------------------- | -------------------------------------------------------- |
| `~/.pi/agent/gpt-enhance.json`              | User-level configuration                                 |
| `.pi/gpt-enhance.json`                      | Project-level configuration                              |
| `~/.pi/agent/gpt-enhance-capabilities.json` | Capability cache isolated by provider/API/model/base URL |
| `~/.pi/agent/gpt-enhance-preferences.json`  | Fast preferences isolated by model                       |

The capability cache contains no API keys, request content, or response content.

## Development verification

```bash
bun run --filter pi-gpt-enhance typecheck
bun run --filter pi-gpt-enhance test
pi -e ./packages/gpt-enhance
```

Repository-level verification:

```bash
bun run check
npm pack --dry-run --json --workspace pi-gpt-enhance
```

## Sources and license

Server-side capability probing uses the OpenAI Responses `context_management` parameter. Codex model catalog data is maintained separately in [`pi-codex-gpt-metadata`](../codex-gpt-metadata) and registered by [`pi-autofill-model-metadata`](../autofill-model-metadata).

`src/apply-patch.ts` and `src/apply-patch-tool.ts` contain modified Codex-derived implementations provided under Apache-2.0 with the `Copyright 2025 OpenAI` attribution retained. The remaining original code in this package is provided under MIT. The package-level license declaration is `(MIT AND Apache-2.0)`.

The published package includes:

- `LICENSE`
- `LICENSES/Apache-2.0.txt`
- `NOTICE`

This extension is not an official OpenAI Codex product and is not endorsed by OpenAI.
