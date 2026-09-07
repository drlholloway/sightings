# Phase 5 — Application UI (`apps/workbench`)

**Goal:** the screens a user touches: connection status, Identify, History, Reading detail,
Parts & Bins with statistics, Settings, and the log. Adaptive layout for desktop windows and
phones. Curves is Phase 6 but its navigation slot exists from Phase 0.

**Effort:** 5–8 days. **Hardware:** useful but not required — develop against
`FakeTransport` replay + imported `.dcalog` data.

## Screens

### Header / connection bar (always visible)
- Status dot, product name, serial, firmware; Connect/Disconnect button; device picker if
  more than one unit.
- Footer (desktop) / expandable strip (phone): battery V, 12 V rail, Vref, calibrated RMT2 —
  same fields as the reference client's footer.
- Banners: no device found; USB permission denied (Android, with “open settings”); low
  battery / USB voltage fail; Linux udev hint when the device is visible but cannot be opened.

### Identify
- Big **Test** button (disabled while not connected or busy) and a “waiting for unit button”
  hint when idle.
- Result card: component name (e.g. “NPN BJT”), flag chips (SILICON, DARLINGTON…),
  **pinout by lead color** — three circles in red/green/blue with the terminal letter under
  each, exactly as the reference — then the parameter table (label, formatted value).
- Tagging strip directly under the card: part number autocomplete (creates a part on the fly),
  bin dropdown (filtered by part), label, notes, star. Saves on change (debounced) to
  `reading_tags`. A “where does this fall?” line appears when a bin is chosen: e.g.
  “hFE 212 — 63rd percentile of 41 in bin ‘2N3904 lot A’” with a tiny histogram and a marker.
- Raw frame in an expandable “details” panel with a copy button.
- **Saving rules.** A result from the app's Test button is saved on arrival and the card
  shows a small “saved #1234” indicator. A result picked up from the **unit's own button**
  arrives as a **draft**: the same card with a “Draft — not saved” header, a **Save** button
  (primary) and a **Discard** button. The tagging strip works on a draft too, so the usual
  flow is clip → press the unit's button → glance at the card → pick part/bin → Save.
- **Drafts tray.** If more drafts arrive before the current one is handled (batch testing a
  bag of parts), they queue in a tray shown as a count badge on the Identify tab and a
  horizontal strip of small draft chips above the card. “Save all with current tag” and
  “Discard all” act on the queue. Keyboard: Enter = Save, Backspace/Delete = Discard.
- Drafts live in memory only; quitting with unsaved drafts asks for confirmation.

### History
- Filter bar: type (multi), part, bin, date range, text (label/notes), “untagged only”, star.
- Virtualised list (desktop: table with sortable columns taken_at / type / part / headline
  values; phone: cards). Tapping opens Reading detail; desktop opens it in the right pane.
- Bulk actions: assign part/bin to selection, export CSV, delete (confirm).

### Reading detail
- Same result card as Identify (rendered from stored params), tagging strip, rails at time of
  reading, session/device info, list of sweeps linked to this reading (opens Curves with the
  sweep loaded), and “Re‑run identify on this part” shortcut when connected.

### Parts & Bins
- Parts list → part page: bins, count of readings, headline distributions.
- Bin page: statistics table per headline key (n, min, p5, p25, median, p75, p95, max, mean,
  σ), histogram with selectable key, scatter of two keys (e.g. hFE vs Vbe) for matching,
  list of member readings sortable by the selected key, “find closest matches” (pick a
  reading, list the k nearest in the chosen key — useful for transistor matching).
- Export bin CSV.

### Settings
- Auto‑connect on attach; “treat unit‑button results as drafts” (default on; off = save
  immediately like app tests); units/precision; theme;
  database location and size; **Backup** / **Restore**; “Re‑decode all readings”;
  log export; about/version; link to hardware notes (Linux udev, Android OTG).

### Log
- The transport/service log with level filter and copy/export — the reference client's
  Log tab.

## Architecture in the app
- `flutter_riverpod` providers: `deviceServiceProvider`, `repositoryProvider`,
  `readingsFilterProvider`, `selectedReadingProvider`, `binStatsProvider(binId, key)`.
- `go_router` routes: `/identify`, `/curves`, `/history`, `/history/:id`, `/parts`,
  `/parts/:id`, `/bins/:id`, `/settings`, `/log`. Desktop two‑pane wraps list + detail.
- Widgets shared with Phase 6: `ResultCard`, `PinoutWidget`, `ParamTable`, `EngText`
  (uses `eng()` from the protocol package), `HistogramChart` (`fl_chart`).
- Formatting lives in one place (`format.dart`): engineering notation, dates, percentiles.

## Tasks
1. Design tokens and theme (light/dark), typography with tabular numerals for values.
2. Header/footer/banners bound to `DeviceStatus`.
3. Identify screen + `ResultCard` family; tagging strip with autocomplete.
4. History list with filter + paging; desktop table variant.
5. Reading detail.
6. Parts & Bins pages; histogram/scatter; nearest‑match.
7. Settings incl. backup/restore flows (file picker on desktop, share/SAF on Android).
8. Log screen.
9. Widget tests: result card renders every component type from golden frames; pinout colors
   match config tables; tagging writes to the repository (in‑memory DB).
10. Accessibility pass: semantics on pinout circles (“Base on green lead”), keyboard
    navigation on desktop (Space = Test, Cmd/Ctrl‑S = save tag, Esc = cancel sweep).

## Acceptance criteria
- With `FakeTransport` replay, a full session (connect → identify × N → tag → history →
  bin stats) works on macOS, Linux and an Android phone layout.
- A scripted unit‑button result appears as a draft, is not in the database until Save, and
  is gone after Discard; three queued drafts can be saved in one action.
- On hardware, a unit‑button test appears in the Identify screen within one poll interval
  and is saved.
- Bin page shows correct percentiles against a seeded dataset (unit‑tested numbers).
