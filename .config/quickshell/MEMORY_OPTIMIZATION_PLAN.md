# Memory optimization plan — Quickshell bar

**Status:** proposal only. No QML was changed while producing this document.
**Implementation:** M1–M9, M12 and M13 are implemented in the working tree (uncommitted);
M10 and M11 were left alone. The sections below keep the original analysis.
**Scope:** everything under `~/.config/quickshell` (bar, popups, services, notification daemon, wallpaper picker).
**Goal:** reduce steady-state and peak memory without changing behaviour or making the bar feel slower.

---

## 0. TL;DR

The bar already has the right idea in `widgets/BarPopup.qml`: a heavy subtree is declared as a
`Component`, instantiated only while the popup is live, then destroyed. The biggest remaining
wins are where that contract is *not* applied:

1. **Toasts are instantiated on every screen.** `NotificationToasts.qml` creates one
   `PanelWindow` + `ListView` + `ScriptModel` per monitor. Only the focused monitor's window is
   visible, but the others still build their delegates while toasts exist. Fix: gate the
   model/content on `win.visible`, or use a single window.
2. **`cacheBuffer: 4000` in three list views.** `NotificationPanel`, `AppMixerList` and
   `WifiNetworkList` deliberately instantiate thousands of pixels of off-screen delegates to get
   an exact `contentHeight`. In every case the height is **capped** shortly afterwards, so exact
   height only matters for the small-list case. A cap-sized cache gets the same result for far
   less memory.
3. **Images are decoded at source resolution.** `RoundedImage` has no `sourceSize`, and
   `NotificationCard` uses it for notification images. A 1080p notification image is ~8 MB
   decoded; a 4K one is ~33 MB. Cover art and screenshots are the largest single allocations in
   the process.
4. **Notifications are retained forever.** `NotificationServer` keeps every tracked notification
   across reloads (`keepOnReload: true`), with `imageSupported: true` and no count cap. A busy
   desktop grows this without bound.
5. **Small images use `MultiEffect` + a mask texture.** `RoundedImage` allocates an effect
   pipeline and mask layer for 28–36 px avatars. A `ClippingRectangle` (Qt ≥ 6.7) or an
   unrounded image is much cheaper for icons.

Everything else in this document is secondary: duplicate Pipewire trackers, per-screen
`hyprctl` processes, retained Wi-Fi models, tray menu anchors, and dead code.

---

## 1. Baseline (measured, not estimated)

Taken on the running session while writing this plan:

| Metric | Value |
|---|---|
| Process | `qs` (pid 334007) |
| Screens | 2 — DP-2 2560×1440, HDMI-A-2 1920×1080 |
| Uptime at measurement | ~10 min |
| RSS | 375,372 kB (~366 MiB) |
| PSS | 207,377 kB (~203 MiB) |
| Private dirty (anon) | 169,976 kB (~166 MiB) |
| `memfd:JSGCHeap:QtQml` | 1,968 kB (~2 MiB) |
| Threads | 21 |
| Mapped layer surfaces | 2 Quickshell bar windows (`hyprctl layers -j`; plus awww wallpaper surfaces) |

Important caveats:

- RSS is inflated by shared file-backed pages, notably `libLLVM` (~40 MB) and
  `libgallium` (~40 MB). **PSS and `Pss_Anon` are the useful numbers** for this work.
- Only ~2 MB is JS heap. The problem is native QML objects, delegate trees, decoded images,
  font/shader caches, and graphics-driver allocations — not JavaScript logic.
- Closed `PopupWindow`s do **not** appear in `hyprctl layers`; they are unmapped at rest. So this
  plan should not overstate "surface" savings. The cost of closed popups is the QML object graph,
  not a mapped Wayland surface.

A second baseline should be captured with a repeatable scenario matrix (section 6) before
changing anything, so we can tell real wins from noise.

---

## 2. How to think about the cost

A useful approximation for this bar:

```
resident ≈ baseline(Qt/Mesa/fonts)
         + Σ live QML items (one bar tree per screen)
         + Σ cached off-screen delegates (cacheBuffer × row cost)
         + Σ decoded image pixels (width × height × 4 × copies)
         + Σ retained backend data (notifications, APs, streams, menus)
         + Σ effect/offscreen textures (MultiEffect, layers)
```

The multipliers are what matter:

- **Screens (`S`)** — anything inside `Variants { model: Quickshell.screens }` exists `S` times.
- **Items (`N`)** — notifications, Wi-Fi APs, audio streams, tray items.
- **Pixels (`P`)** — image memory scales with the *decoded* size, not the displayed size, unless
  `sourceSize` is set.
- **Retention time (`T`)** — data kept after the UI that showed it is gone.

### 2.1 The `BarPopup` contract to copy

`BarPopup.qml` already does the right lifecycle:

| Phase | What exists |
|---|---|
| closed (`phase === 0`) | `PopupWindow`, anchor, focus grab, `Loader` (inactive), `Component` definition |
| entering/leaving (`phase 1/3`) | full content instance, kept alive for the exit animation |
| open (`phase === 2`) | same instance |
| after exit | `Loader.active = false` → content subtree destroyed |

That gives three reusable rules:

1. **Keep the declaration, drop the instance.** A `Component` is cheap; an instantiated subtree
   is not.
2. **Hold through the exit animation, then unload.** Do not unload on the first "hide" event if
   there is an exit transition.
3. **Expose a small sizing interface.** `BarPopup` reads `contentItem.shownHeight` /
   `fullHeight` instead of coupling the window to the content's internals. Keep that pattern
   when making other things lazy.

The plan below is mostly "apply this contract one more level down" and "stop paying for
off-screen delegates and full-resolution pixels".

### 2.2 What is already good (do not regress)

- `BarPopup` unloads content after close. Keep it.
- `WallpaperPicker` uses `LazyLoader { active: root.shown }` and destroys the whole window.
  Keep it.
- `ClockComp` uses a `Loader` for its calendar, although it is currently unused.
- `Bar.qml` only constructs one `WallpaperPicker` at the root, not per screen.

---

## 3. Findings, ranked

Impact is a judgement based on the mechanisms above, not a measured per-item number.
Effort is relative to the current codebase.

| ID | Finding | Impact | Effort | Risk |
|---|---|---|---|---|
| M1 | Toast window + delegates duplicated per screen | High | Low | Low |
| M2 | `cacheBuffer: 4000` in three lists | High (peak) | Low–Med | Low–Med |
| M3 | Notifications retained unbounded | High (over time) | Low–Med | Medium (UX) |
| M4 | Images decoded at full source size | High | Low | Low |
| M5 | `MultiEffect` + mask for tiny images | Medium | Low | Low–Med |
| M6 | Notification card builds both image and icon branch | Medium | Low | Low |
| M7 | Wi-Fi model + `Connections` per AP retained while closed | Medium | Med | Low–Med |
| M8 | Duplicate Pipewire `PwObjectTracker`s | Low–Med | Low | Low |
| M9 | Per-screen `hyprctl` process for active window | Low–Med (CPU/churn) | Low | Low |
| M10 | Closed popups keep window/focus-grab/region objects | Low | Med–High | Medium |
| M11 | Tray menu anchors duplicated per screen | Low | Med | Low |
| M12 | Time service formats five strings every second | Low | Low | Low |
| M13 | Dead code / unused objects | Low | Low | Low |

---

## 4. Detailed findings

### M1 — Toast content is instantiated on every screen

**Where:** `widgets/NotificationToasts.qml:16-24` (`Variants { model: Quickshell.screens }`),
`26-49` (one `PanelWindow` per screen), `51-110` (`ListView` + `ScriptModel` + delegates).

**Mechanism:** each monitor gets its own toast window. The window is only visible on the focused
monitor, but the `ListView` in the other windows still has a non-empty model while toasts exist,
so it still creates `NotificationToast` → `NotificationCard` delegate trees. Each card can hold
an image and a `MultiEffect` (see M4/M5). With `S` screens and `T` toasts, the naive cost is
`S × T` cards instead of `T`.

**Proposed change (minimal):** keep the per-screen windows, but make the model empty on
non-visible windows:

```qml
ScriptModel {
    values: win.visible ? NotificationService.toasts : []
}
```

or wrap the `ListView`/`ScriptModel` in a `Loader { active: win.visible }`. The hidden windows
then hold only a `PanelWindow` and an empty `Loader`. This preserves the current "toast only on
the focused monitor" behaviour and avoids refactoring screen tracking.

**Optional structural version:** replace the `Variants` with a single `PanelWindow` whose
`screen` follows `Hyprland.focusedMonitor`, wrapped in a `LazyLoader`/live-phase loader. This
saves `S − 1` windows and their object graphs too, but changing `screen` on a mapped layer
surface has edge cases (focus changes, monitor hotplug). Treat it as a follow-up, not the first
edit.

**Expected impact:** high whenever toasts are visible; zero at rest when there are no toasts.

**Watch out:** if the toast window is unloaded immediately when the last toast hides, the
`remove` transition will not play. Gate on "has toasts or exit animation running", using the same
`phase` idea as `BarPopup`, or accept that the exit animation is cut when the window is hidden.

---

### M2 — `cacheBuffer: 4000` is used to make `contentHeight` exact, but the height is capped

**Where:**

- `widgets/NotificationPanel.qml:111`
- `widgets/AppMixerList.qml:99`
- `widgets/WifiNetworkList.qml:50`

All three comments say the same thing: keep every delegate instantiated so `contentHeight` is
not an estimate.

**The key insight:** in each case the consumer only needs an exact height *below a cap*.

- `NotificationPanel.qml:23-27`: `listHeight = 8 + Math.min(list.contentHeight, maxListHeight)`,
  with `maxListHeight: 260`. Once the list is taller than 260 px, the exact value beyond 260 is
  discarded.
- `AppMixerList.qml` is used by `AudioComp.qml:179-181`:
  `shownHeight = baseHeight + (streamCount > 0 ? 24 + Math.min(appList.wantedHeight, 280) : 0)`.
  Again, exact height only matters up to 280 px.
- `WifiNetworkList.qml:30` feeds `NetworkComp.qml:91-94`, and `NetworkComp` clamps the body to
  `maxHeight: 440` at line 66. Exact height only matters up to 440 px.

So a `cacheBuffer` that covers the cap (plus one row) is sufficient. `4000` px of off-screen
delegates are created for no benefit once the list exceeds the cap.

**Proposed change:** set `cacheBuffer` to roughly `cap + 2 × rowHeight`:

| View | Cap | Suggested cacheBuffer |
|---|---|---|
| NotificationPanel | 260 px | ~600 |
| AppMixerList | 280 px | ~600 |
| WifiNetworkList | 440 px | ~900 |

Then verify the small-list cases (1–5 items) still produce an exact height. If they do not,
the fallback is to compute an estimate from the model (`count × baseRowHeight`, with a small
allowance for variable-height notification bodies / the password row) and let the popup's
`bodyHeight` settle once delegates are created. The popup already animates `bodyHeight`, so a
one-frame correction is visually acceptable.

**Expected impact:** high peak memory when opening the dash/audio/network popup with many items;
no effect when the popups are closed. It removes the worst transient spikes.

**Watch out:** do not set `cacheBuffer: 0` blindly. `ListView.contentHeight` for uncreated items
is an estimate, and a popup whose height oscillates while scrolling looks broken. Size the buffer
to the cap, not to zero.

**Second-order cleanup:** `NotificationPanel.qml:111` and the other two views could share one
small helper/comment explaining the cap-aware rule, so future edits do not "fix" the buffer back
to 4000.

---

### M3 — Notifications are retained without a bound

**Where:** `services/NotificationService.qml:29-40` (`tracked`, `newestFirst`),
`180-207` (`NotificationServer`, `imageSupported: true`, `persistenceSupported: true`,
`keepOnReload: true`).

**Mechanism:** every notification is marked `tracked = true` and stays in
`server.trackedNotifications`. Nothing ever removes old ones. `keepOnReload` carries them across
QML reloads. The `image` property is a string and is often a data URI or a path; a screenshot
notification can retain megabytes indefinitely. Over a day of desktop use this is the main
"memory grows while idle" risk.

**Proposed change (needs a product decision):**

1. Add a cap, e.g. `property int maxTracked: 50`. After `n.tracked = true`, if
   `tracked.values.length > maxTracked`, dismiss the oldest notification(s).
2. Or keep the full list but advertise `imageSupported: false` if notification images are not
   important. This removes the largest payload but loses a feature.
3. Or keep images only for the newest `K` notifications and dismiss older ones. Since
   `Notification.image` is readonly, "clearing" an image in place is not possible; dismissal is
   the only supported way to release it.

Also consider whether `keepOnReload: true` is wanted. It preserves notifications across a QML
reload, but it also means a reload never gives you a clean slate. If it is kept, the cap should
be applied at startup to the carried-over list as well.

**Expected impact:** high over long sessions; low on a fresh start. This is the difference
between "flat memory" and "grows until restart".

**Watch out:** dismissing old notifications sends a `NotificationClosed` signal to the sending
application. That is normal notification-daemon behaviour, but it is a UX choice. Do not add a
cap without deciding what "old" means (count vs age vs urgency). Critical notifications probably
deserve to stay longer.

---

### M4 — Images are decoded at source resolution

**Where:**

- `widgets/RoundedImage.qml:10-16` — the inner `Image` has no `sourceSize`.
- `components/PlayerComp.qml:93-103` — bar cover art displayed at 28 px.
- `widgets/PlayerPanel.qml:88-92` — popup cover art displayed at ~312 px.
- `widgets/NotificationCard.qml:79-84` — notification image displayed at 36 px.

Wallpaper thumbnails are the exception and already bound their decode size
(`components/WallpaperPicker.qml:202-203`).

**Mechanism:** Qt Quick decodes an `Image` at its natural size unless `sourceSize` is set. A
1080p notification image decodes to 1920 × 1080 × 4 ≈ 8.3 MB; a 4K image to ≈ 33 MB. Displaying
it at 36 px does not reduce the decode. QML's pixmap cache may share a decoded image between
items with the same source, but it cannot share between different sources, and `MultiEffect`
adds its own textures.

**Proposed change:** give `RoundedImage` a decode-size property and set it from the caller:

```qml
// RoundedImage.qml
property int decodeWidth: 0
property int decodeHeight: 0

Image {
    sourceSize.width: decodeWidth > 0 ? decodeWidth : width
    sourceSize.height: decodeHeight > 0 ? decodeHeight : height
    asynchronous: true
}
```

Callers pass the display size (the bar art 28, the panel art `root.artSize`, the notification
icon 36). For transient popups, consider `cache: false`; for the always-visible bar art, caching
one small decode may be better than re-decoding on every track change.

**Expected impact:** high for notification screenshots and high-resolution album art; low for
icons. This is one of the cheapest changes per byte saved.

**Watch out:** `sourceSize` is in logical pixels and interacts with the device pixel ratio.
Verify sharpness on a HiDPI screen, and do not shrink so far that the image looks soft. Set the
size from the actual displayed pixels, not from a hard-coded guess.

---

### M5 — `MultiEffect` + mask for 28–36 px images

**Where:** `widgets/RoundedImage.qml:18-33` — a hidden `Rectangle` with `layer.enabled: true`
is used as a mask, and a `MultiEffect` composites the image through it.

**Mechanism:** even for a tiny image, the effect path allocates a source texture, a mask texture
and a result, plus shader/graphics resources. `RoundedImage` is used in the bar (per screen), in
the player panel, and in every notification card. For notification cards this multiplies with
M2/M3.

**Proposed change:** use `Quickshell.Widgets.ClippingRectangle` (available in this Quickshell
version, requires Qt ≥ 6.7) for the rounded-image case:

```qml
ClippingRectangle {
    radius: ...
    Image { anchors.fill: parent; source: ...; sourceSize: ... }
}
```

`ClippingRectangle` is more expensive than a plain `Rectangle`, but it avoids the separate mask
layer and the `MultiEffect` pipeline. For the smallest images (28 px bar art, 36 px notification
avatar) consider whether rounded corners are worth it at all; a plain image with an inset
background is the cheapest option.

**Expected impact:** medium, and it compounds with M4. The largest effect is in notification
lists where many `RoundedImage` instances coexist.

**Watch out:** visual differences at corners (antialiasing, border overlap). Test against the
current look. Do not replace every `Rectangle` with `ClippingRectangle`; it is only for places
that genuinely need clipping.

---

### M6 — `NotificationCard` builds both the image and the icon branch

**Where:** `widgets/NotificationCard.qml:74-92`.

**Mechanism:** each card instantiates `RoundedImage` (image + mask + `MultiEffect`) *and*
`AppTile` (a `Rectangle`, an `IconImage`, and a `Text`), then hides one with `visible`. For the
common no-image notification, the whole `RoundedImage` subtree is dead weight. With `cacheBuffer`
(M2) this is multiplied by every card.

**Proposed change:** use a `Loader` for the branch:

```qml
Loader {
    active: root.hasImage
    sourceComponent: Component {
        RoundedImage { /* ... */ }
    }
}
AppTile { visible: !root.hasImage; /* ... */ }
```

or a single `Loader` whose `sourceComponent` is chosen between the two components. This is
exactly the `BarPopup` pattern at the item level: declare both, instantiate one.

**Expected impact:** medium in the notification dash and toast lists; low elsewhere.

**Watch out:** do not introduce a one-frame blank avatar; both branches are cheap to create, so
first-open latency is negligible.

---

### M7 — Wi-Fi model and per-network `Connections` are retained while the panel is closed

**Where:** `services/NetworkService.qml:105-110` (`wifiModel`), `301-311` (`Instantiator` of one
`Connections` per network), `components/NetworkComp.qml:69-77` (acquire/release scan on live).

**Mechanism:** the scan itself is already ref-counted and only runs while the popup is live.
However:

- `wifiModel` keeps the deduped array of every AP after the popup closes.
- `Instantiator` creates a `Connections` object per network, permanently, to catch
  `connectionFailed`. In a dense environment (dozens or hundreds of APs) that is a lot of
  QObjects and signal connections for a panel that is closed almost all the time.

The backend (`Networking`) still holds the network objects; the savings here are the duplicate
JS array and, more importantly, the per-network `Connections`.

**Proposed change:**

1. Make the `Instantiator` active only while the panel is live:
   ```qml
   Instantiator {
       active: root.scanClients > 0
       model: root.wifiDevice ? root.wifiDevice.networks : null
       // ...
   }
   ```
   Connection failures that happen while the panel is closed cannot be shown anyway; the panel
   re-attaches when it opens.
2. Optionally clear `wifiModel.values` when `scanClients === 0`:
   ```qml
   values: root.scanClients > 0 ? root.buildNetworkList() : []
   ```
   This drops the duplicate array and its references while closed. It also makes the popup
   rebuild once on open, which is acceptable.
3. Investigate whether the `WifiDevice` exposes a single `connectionFailed`/state signal. If it
   does, replace the `Instantiator` entirely with one `Connections`. If the signal is only on
   `WifiNetwork`, keep the gated `Instantiator`.

**Expected impact:** medium in dense Wi-Fi environments; low at home. The peak while the panel is
open is also improved by M2.

**Watch out:** `lastError` / `passwordRejected` must still work for a failure that happened just
before opening the panel. Either accept that state is only tracked while open, or keep the last
error as a plain string in the service (it already is) and do not depend on per-network
connections for it.

---

### M8 — Duplicate Pipewire trackers

**Where:**

- `services/Audio.qml:101-109` tracks the default sink and source.
- `widgets/MixerEntry.qml:27` tracks `node` again for the same sink/source.
- `widgets/MixerGroup.qml:68` tracks `root.nodes`.
- `widgets/AppStreamRow.qml:36` tracks `root.node` again inside every group.

**Mechanism:** `PwObjectTracker` is a QObject that keeps Pipewire properties alive/updated for a
set of nodes. Tracking the same node from a parent and a child duplicates the tracker, its
bindings, and its object references. With many app streams this adds up; the memory per tracker
is small, but the duplication is unnecessary and makes ownership unclear.

**Proposed change:** centralize tracking.

- `Audio` already has the default sink/source trackers. Remove the `PwObjectTracker` in
  `MixerEntry`.
- `MixerGroup` tracks all nodes in the group, including the single-stream case, so remove the
  `PwObjectTracker` in `AppStreamRow` (it is only used inside `MixerGroup` in this codebase).
- If `Audio` tracks all `sinks` (not just the default), `MixerGroup` can drop its tracker too.
  That would give one tracker set in the singleton and none in the views.

**Expected impact:** low–medium. This is more about binding/ownership hygiene than a dramatic
number, but it is easy and safe once the "who tracks what" rule is written down.

**Watch out:** Pipewire nodes expose properties asynchronously. If a view renders a node that no
tracker covers, the row will show blank/zero values. Verify every node used by a row is in the
central tracked set.

---

### M9 — Per-screen `hyprctl` process for the active window

**Where:** `components/ActiveWindow.qml:68-75` (every Hyprland raw event starts
`getActiveClient`), `152-169` (one `Process` per instance, `running: true`), and
`services/Hyprland.qml:41-56` (another `Process` on every event).

**Mechanism:** `ActiveWindow` is instantiated once per screen (`Bar.qml:155-162`), so two screens
mean two `hyprctl activewindow -j` processes per event, plus JSON parsing and string allocations.
`services/Hyprland.qml` already exposes `activeToplevel`, which carries `title`, `monitor` and
`wayland.appId` from Quickshell's own Hyprland state. The bar is paying for a subprocess to
recompute information it already has.

**Proposed change:** bind `ActiveWindow` to `Hyprland.activeToplevel` instead of running
`hyprctl`. Use `Hyprland.activeToplevel?.wayland?.appId` for the class and
`Hyprland.activeToplevel?.monitor` for the monitor, then keep the existing `formatClass()`
mapping. This removes the per-screen `Process`, the `Connections` handler, and the `-j` parse
churn. If `appId` is not populated for XWayland windows, fall back to `lastIpcObject.class`
after a `refreshToplevels()` (see docs), or keep the process as a temporary fallback on the
singleton only.

**Expected impact:** low–medium. It is mostly CPU/GC and process churn, but it also removes two
`QProcess` objects and their buffers per screen.

**Watch out:** verify `appId` vs `class` for XWayland and for apps like Spotify/Steam that the
current mapping special-cases. Keep the `formatClass` table; only change the data source.

---

### M10 — Closed popups still keep window/focus-grab/region objects

**Where:** `widgets/BarPopup.qml:7-88`; five `BarPopup` instances per screen (Dash, Player,
Battery, Audio, Network) plus any future ones.

**Mechanism:** the heavy content is already unloaded, which is the important part. What remains
per popup is a `PopupWindow`, a `HyprlandFocusGrab`, a `Region` mask, a `Loader`, and the
`Component` definition. `hyprctl layers` confirms these are not mapped at rest, so the surface
cost is not the issue; the object graph and any focus-grab bookkeeping are.

**Proposed change:** do not refactor this first. Measure it. If it shows up:
- Make the `HyprlandFocusGrab` lazy (`Loader { active: popup.live }`) and adjust the
  `grabActive` alias to tolerate a null item.
- Or replace the five per-widget popups with one popup host per screen whose `Loader` swaps
  between content components. This saves four windows/focus grabs/regions per screen but is a
  real architectural change (anchoring, sizing, open/close state).

**Expected impact:** low at current scale; possibly medium on 3+ monitor setups with many future
popups. Mark as "measure before touching".

**Watch out:** `BarPopup` is the best-behaved part of the codebase. Any refactor here risks
regressing the exit animation, focus grab, or input mask. Prefer leaving it alone unless a
profile says otherwise.

---

### M11 — Tray menu anchors duplicated per screen

**Where:** `components/Tray.qml:25-36` (one `TrayItem` per tray item per screen),
`widgets/TrayItem.qml:28-39` (one `QsMenuAnchor` per item, with `menu: item.menu`).

**Mechanism:** every tray item gets a `QsMenuAnchor` and a `QsMenuHandle` on every monitor. The
handle may or may not eagerly fetch the DBusMenu tree. With many tray apps this is duplicated
menu state for a menu that is rarely open.

**Proposed change:** investigate whether `QsMenuAnchor`/`QsMenuHandle` fetches eagerly. If it
does, create the anchor on demand (right-click) via a `Loader`, or keep one anchor per item and
share it across screens. If it is already lazy, leave it.

**Expected impact:** low unless the tray has many apps with large menus. Worth a quick check,
not a rewrite.

**Watch out:** `QsMenuAnchor` needs an `Item` to anchor to; creating it lazily inside the click
handler requires a small amount of state (which item was right-clicked).

---

### M12 — `Time` formats five strings every second

**Where:** `services/Time.qml:14-28`, driven by `SystemClock { precision: SystemClock.Seconds }`.

**Mechanism:** `time`, `timeI`, `date`, `fancyDate` and `year` are all recomputed every second.
Only `timeI` is used in the bar; `time` and `fancyDate` are used by the dash, which is closed most
of the time. This is not a large allocation, but it is continuous garbage and binding churn.

**Proposed change:** split the clock:
- a minute-precision `SystemClock` for `timeI`, `date`, `fancyDate`, `year`;
- a seconds-precision clock only while the dash is open, or keep `time` seconds and accept it.

**Expected impact:** low. Include only if touching `Time.qml` for another reason.

---

### M13 — Dead code and unused objects

**Where / what:**

- `components/ActiveWindow.qml` and `widgets/Workspace.qml` each declare a `Process`; the one in
  `Workspace.qml:61-63` is never used. `Workspaces.qml:62-70` creates 10 of them per screen.
- `components/AudioComp.qml:514-646` is a large commented-out block. `ClockComp.qml` is unused
  (`Bar.qml:73-81` is commented out).
- Numerous unused imports (`QtQuick.Controls`, `Quickshell.Io`, etc.) across components.

**Mechanism:** unused `Process` objects are real `QProcess` instances (even when not running).
Commented code does not instantiate, but it inflates parse/compile work on reload and makes dead
components look live.

**Proposed change:** remove the unused `Process` in `Workspace.qml`, delete the commented blocks
when touching those files, and remove `ClockComp.qml` if it is confirmed unused. This is cleanup,
not a major win.

**Watch out:** `Workspace.qml` has a `Process` that may have been intended for an IPC action;
check git history before deleting. The unused one has no `command` and no references.

---

## 5. Suggested order of work

### Phase 0 — measure and pin the baseline

- Capture `smaps_rollup`, `Pss_Anon`, `hyprctl layers -j`, and a scenario log (section 6).
- Run once with no notifications and once with a synthetic burst of image notifications.
- Do not change code until the baseline is repeatable.

### Phase 1 — cheap, high-confidence wins (P0)

1. **M1** — gate toast content on `win.visible`.
2. **M4** — add `sourceSize` to `RoundedImage` callers.
3. **M2** — cap-aware `cacheBuffer` in the three lists.
4. **M6** — `Loader` for the image/icon branch in `NotificationCard`.
5. **M5** — replace `MultiEffect` with `ClippingRectangle` for small images.

These are local edits, easy to review, and should show the largest improvement in peak memory
with little behavioural risk.

### Phase 2 — retention and duplication (P1)

6. **M3** — decide and implement a notification cap.
7. **M7** — gate the Wi-Fi `Instantiator`/model on `scanClients`.
8. **M8** — centralize Pipewire tracking.
9. **M9** — move active-window state to the Hyprland singleton.

### Phase 3 — cleanup and speculation (P2)

10. **M10** — profile closed popups before refactoring.
11. **M11** — inspect tray menu laziness.
12. **M12 / M13** — time formatting and dead code, only while touching those files.

---

## 6. Verification plan

### 6.1 Metrics

For each run, record:

```sh
PID=$(pgrep -x qs | head -1)
ps -o pid,rss,vsz,nlwp,etime -p "$PID"
cat /proc/$PID/smaps_rollup
hyprctl layers -j | jq '[.[] | .levels["2"][]? | .namespace] | group_by(.) | map({ns: .[0], n: length})'
```

Prefer **`Pss_Anon`** (private anonymous) and **`Pss`** over RSS. RSS includes shared Mesa/LLVM
pages and will stay high even after QML objects are freed.

If available, use `heaptrack` or `valgrind --tool=massif` for a one-off attribution run. The
`memfd:JSGCHeap` size already tells us JS is not the problem, so focus on native allocations.

### 6.2 Scenario matrix

Run each scenario from a fresh `qs` start, and also after 10 minutes of idle:

| # | Scenario | What it stresses |
|---|---|---|
| S0 | Cold start, 2 monitors, no notifications | baseline bar tree |
| S1 | 100 notifications, 50 with 1080p images; open dash | M2, M3, M4, M5, M6 |
| S2 | Repeat open/close dash 10× | whether cards/images are released |
| S3 | 3 toasts on 2 monitors; switch focus | M1 |
| S4 | 100 Wi-Fi APs; open/close network popup 5× | M2, M7 |
| S5 | 10 audio streams; open/close audio popup 5× | M2, M8 |
| S6 | Open every popup once, close all, idle 5 min | retained objects after close |
| S7 | 20 tray items with menus; open a menu | M11 |
| S8 | One day of normal use | M3 growth over time |

For each scenario, record before/after values for the metric above and note whether the value
returns to the S0 baseline after closing the popup. A number that never returns is a retention
bug; a number that returns but peaks high is a transient-delegate/pixel problem.

### 6.3 Acceptance criteria

- S0 `Pss_Anon` must not regress.
- S1/S4/S5 peak must drop, and must return to S0 after closing.
- S3 must show only one toast card per toast in memory (or at least the non-focused windows must
  have no delegates).
- S8 must be flat (within noise) after the notification cap, rather than monotonically growing.
- No visual regressions in popup height, exit animation, image sharpness, or focus grab.

---

## 7. Open questions / checks before implementing

1. **Does a `PanelWindow` with `visible: false` still create its `ListView` delegates?**
   Expected yes (QML items exist independently of mapping). Verify with S3; if not, M1 is only a
   surface/object win, not a delegate win.
2. **Does `QsMenuAnchor`/`QsMenuHandle` fetch the DBusMenu tree eagerly?** Check the
   Quickshell source or measure S7. If lazy, M11 drops out.
3. **Does QML share decoded pixmaps between `Image`s with the same `source` and `sourceSize`?**
   If yes, M4's win is per unique image, not per item. If no, the win is even larger.
4. **Does `WifiDevice` expose a single `connectionFailed` signal?** If yes, M7's `Instantiator`
   can be deleted entirely.
5. **Is `ClippingRectangle` acceptable with the current Qt version and visual style?** It
   requires Qt ≥ 6.7. The running Qt is 6.12, so it is available; test corners.
6. **What is the desired notification retention policy?** Count cap, age cap, urgency-aware, or
   no persistence at all. This is the only finding that needs a product decision.
7. **Are all five `BarPopup`s needed per screen, or can one shared host serve them?** Only
   worth answering if M10 shows up in a profile.

---

## 8. Things not to do

- Do not remove `BarPopup`'s `Loader` or its `active: popup.live` contract. It is the model for
  the rest of the work.
- Do not set `cacheBuffer: 0` without a height strategy; it trades memory for layout jitter.
- Do not decode images at full size "because it looks sharper"; set `sourceSize` to the display
  size and verify on HiDPI.
- Do not replace every `Rectangle` with `ClippingRectangle`; it is more expensive and only pays
  off where clipping is actually needed.
- Do not change the toast visibility model (focused monitor only) while doing memory work; that
  is a separate UX decision.
- Do not trust RSS alone. Use PSS/`Pss_Anon` and a repeatable scenario.
