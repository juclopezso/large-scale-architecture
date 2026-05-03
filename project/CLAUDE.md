# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project context

Large-Scale Software Architecture course (LSSA 2026-I), Universidad Nacional de Colombia. The goal is to design, model, and verify the architecture of the **National Emergency Response and Crisis Management System** — a System of Systems (SoS) composed of five subsystems. This team owns the **s2_notification** subsystem.

Deadline: **Monday May 4, 2026, 23h59**. Submission is a `.zip` named `group-G-team-X-p` uploaded to Google Classroom.

## Pending deliverables

| File | Status | Notes |
|---|---|---|
| `delivery/metamodel.tx` | Done (shared with all 5 teams, must be identical) | |
| `delivery/sos_model.sos` | **Missing** | Shared SoS-level model — also identical across teams |
| `delivery/subsystem_model.sos` | Done | s2_notification subsystem |
| `delivery/verification.ipynb` | **Missing** | 4 iterative verification cycles, Python/Jupyter, Google Colab preferred |
| `delivery/report.pdf` | **Missing** | Written report |

## Metamodel architecture (`metamodel.tx`)

The grammar has **two levels of abstraction** instantiated by the same metamodel:

**SoS-level model** (`sos_model.sos`): only `system` blocks connected via `connectorSystem`. No `component` declarations needed — systems are opaque to each other.

**Subsystem-level model** (`subsystem_model.sos`): full internal C&C — `component` declarations, internal `connector`s, and external `connectorSystem`s that cross system boundaries.

### Key grammar rules

- `ConnectorSystem` accepts `ComponentSystem` (= `Component | System`) in both `from` and `to`. In the SoS model use `system → system`; in the subsystem model you may use `component → system` or `system → component`.
- `Connector` only connects `[Component]` references — never systems.
- `connector` properties use `{ }` syntax; `component`/`system` properties use `( )` syntax.

### ConnectorSystem placement convention

A `connectorSystem` must be declared **inside the emitting system** (the one initiating the connection). The receiving system has no corresponding entry.

### TierType / ComponentType / ConnectorType

Choose types based on semantics, not data movement alone:
- `publisher` / `subscribed` for message-bus interactions
- `db_write_or_read` for any storage access
- `HTTP` for synchronous external calls
- `event_notification` for fire-and-forget async signals
- `control_command` for imperative commands (usually cross-system)
- `data_flow` / `dependency` / `iot_device` as fallbacks

Properties defined on a system in `sos_model.sos` do **not** need to be repeated in `subsystem_model.sos` (they are inherited by convention).

## Verification notebook structure

Four mandatory iterations in `verification.ipynb`:

1. **Iteration 1** — parse `subsystem_model.sos` with textX, visualize C&C, simulate one quality scenario on the initial architecture.
2. **Iteration 2** — introduce architectural tactics/patterns to improve the quality attribute from Iteration 1; re-verify and compare.
3. **Iteration 3** — verify a *different* quality scenario on the evolved architecture.
4. **Iteration 4** — introduce tactics for Iteration 3's scenario; verify and compare.

Close the notebook with a **summary table or comparative chart** showing how quality attributes improved across iterations. Each iteration must include: model instantiation, graphical representation (C&C + deployment view if applicable), simulation, and analysis.

Quality scenario structure: **Stimulus · Source · Environment · Artifact · Response · Response Measure**.

## Reference lab: `delivery/lssa_2026i_l5_notification.ipynb`

Lab #5 is the direct predecessor to `verification.ipynb`. It implements the same subsystem simulation pattern and should be used as a template.

### Simulation framework (reuse as-is)

- **Classes**: `Component`, `PresentationTier`, `LogicTier`, `ExternalServiceTier`, `DataTier`, `Transaction`
- **Load**: `run_simulation()` — 1200 `alert_trigger` + 800 `status_query` concurrent threads
- **Reporting**: `report_metrics()` + `visualize_metrics()`

### Transaction flows
- `alert_trigger`: `api_gateway → data_validator → event_bus → alert_rules_engine_ms → alerts_events_db → notification_emitter → external_channel`
- `status_query`: `api_gateway → event_bus → delivery_state_tracker → delivery_state_db`

### Architecture variants already implemented (map to verification iterations)

| Variant | LB strategy | Notes |
|---|---|---|
| Original | None | 1 instance per component |
| Basic LB | Random | 2 `notification_emitter` replicas |
| Multi-LB | Random at 3 tiers | `api_gateway`, `event_bus` (×3), `notification_emitter` (×2) |
| Round Robin | Cyclic | `event_bus` (×3) + `notification_emitter` (×2) |
| Weighted RR | Weighted cyclic | `event_bus` weights [1,2,3]; `notification_emitter` weights [1,2] |

### Failure injection pattern
`induce_failure()` reduces a critical component's capacity to 50 mid-simulation. In the Weighted RR run: 2000 initial → 0 failed; after failure on `event_bus_1` → 5/2000 failed (only in external channels, WRR absorbed the degradation).

### `verification.ipynb` mapping
- **Iteration 1**: Original architecture + performance/availability scenario
- **Iteration 2**: Apply load balancing tactic (use Multi-LB or RR variant), compare
- **Iteration 3**: Different quality attribute (e.g., reliability or scalability), simulate on evolved arch
- **Iteration 4**: Apply corresponding tactic (e.g., Weighted RR), verify and compare
