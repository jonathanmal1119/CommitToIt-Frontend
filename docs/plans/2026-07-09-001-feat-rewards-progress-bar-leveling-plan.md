---
title: Rewards Progress Bar Leveling - Plan
type: feat
date: 2026-07-09
topic: rewards-progress-bar-leveling
artifact_contract: ce-unified-plan/v1
artifact_readiness: implementation-ready
product_contract_source: ce-brainstorm
execution: code
---

# Rewards Progress Bar Leveling - Plan

## Goal Capsule

- **Objective:** Let the rewards progress bar (`CommitToIt/Views/ProgressBarView.swift`) keep working past the current 400-point cap by deriving its milestone scale live from the point balance, with an odometer-style animation when the balance levels up into a new tier.
- **Product authority:** Resolved in this brainstorm; no external stakeholder sign-off needed.
- **Open blockers:** None.

## Product Contract

### Summary

The rewards progress bar's milestones will scale with the point balance indefinitely instead of capping at 400. Crossing a tier boundary upward animates the milestone numbers with an odometer-style roll in place; crossing back down (via redemption) updates them instantly.

### Problem Frame

`ProgressBarView` hardcodes `total = 400` and shows milestones at 100/200/300. Once `point_balance` reaches 400, the bar is visually maxed out and nothing communicates further progress, even though `point_balance` keeps changing as the user completes tasks (`AppState` increases it) or redeems rewards (`AppState.addUserReward` subtracts `reward.cost`, `CommitToIt/Global/AppState.swift:161`). The bar has no notion of tiers beyond the first one.

### Key Decisions

- **Tier is derived live from `point_balance`, not persisted.** Tier = `floor(point_balance / 400)`, recomputed on every balance change in either direction. There is no "highest level reached" flag. This keeps redemptions honest: if a redemption drops the balance back into a lower tier, the bar reflects that instead of appearing stuck on a tier the balance no longer supports.
- **Odometer-style roll on level-up only.** When the balance crosses a tier boundary upward, the milestone numbers roll in place to the new tier's values; the bar fill itself never resets or flashes. When the balance crosses a boundary downward (redemption), the milestone numbers update instantly with no roll — the roll is reserved for the earning moment, not the spending one.
- **No extra fanfare.** No haptic tap, color glow, or pulse accompanies the transition. The number roll is the entire signal.

### Requirements

- R1. The bar's milestones are derived from `point_balance`: tier = `floor(point_balance / 400)`; milestones are `tier*400 + 100`, `tier*400 + 200`, `tier*400 + 300`; the tier cap is `tier*400 + 400`.
- R2. When `point_balance` increases and crosses upward into a new tier, the milestone labels animate with an odometer-style roll to the new tier's values, and the bar fill does not reset or flash during the transition.
- R3. When `point_balance` decreases and crosses back into a lower tier, the milestone labels update to the new tier's values instantly, without the roll animation.
- R4. On initial render of the view, the milestones for the balance's current tier are shown directly, with no leveling animation played.

### Acceptance Examples

- AE1. **Covers R2.** Given balance at 380 (tier 0, milestones 100/200/300, cap 400). When a completed task raises balance to 420. Then tier becomes 1, milestones roll to 500/600/700, and the bar shows 5% fill within the new tier.
- AE2. **Covers R3.** Given balance at 550 (tier 1, milestones 500/600/700). When a reward redemption drops balance to 300. Then tier becomes 0, milestones instantly show 100/200/300 with no roll, and the bar shows 75% fill within tier 0.
- AE3. **Covers R4.** Given the app launches with `point_balance` already at 900 (tier 2, milestones 900/1000/1100, cap 1200). When the progress bar view first appears. Then it renders those milestones directly with no roll animation.

### Scope Boundaries

- No persisted "highest level reached" state — the tier always follows the current balance.
- No haptic tap or color glow/pulse cue on tier transitions.
- No reset-and-refill or ruler-compression animation styles — considered via visual sketches and dropped in favor of the odometer roll.

Product Contract preservation: unchanged from the brainstorm.

---

## Planning Contract

### Key Technical Decisions

- **Native numeric-text transition for the roll.** Use SwiftUI's built-in `.contentTransition(.numericText())` on the milestone `Text` views rather than a custom digit-roller component. It's the idiomatic API for exactly this effect, is available at the project's iOS 26.2 deployment target, and the codebase has no existing custom number-roll component to extend instead.
- **Decoupled `displayedTier` state.** Track a `@State private var displayedTier: Int?` separate from the tier computed live from `point_balance`. SwiftUI's value-based `.animation(value:)` modifier animates on any change in either direction, so it can't express "roll upward, snap downward, no animation on first render" on its own — an explicit state variable updated through different code paths (animated vs. instant vs. initial) is what makes the directionality possible.
- **Fill width keyed off `displayedTier`, not the live tier.** The fill bar's width is computed from `displayedTier` and `point_balance` together, and the spring animation on that width is suppressed specifically on the frame where a tier crossing updates `displayedTier`. This keeps the crossing from visually sweeping the fill from a high percentage down to a low one (or vice versa) before settling — the behavior the brainstorm's "does not reset or flash" requirement rules out. In-tier progress changes keep the existing spring animation.
- **No model or `AppState` changes.** Tier stays fully derived from `appState.user_stats.point_balance` on every render, consistent with the brainstorm's decision not to persist a "highest tier reached" flag. `UserStats`, `AppState.setUserStats`, and `AppState.addUserReward` are unchanged.

### Assumptions

- No automated test target exists in this repo (single-target SwiftUI app, no XCTest bundle found). Verification for both units is manual/preview-driven rather than XCTest-based; see Verification Contract.

---

## Implementation Units

### U1. Derive tier and milestones from point_balance

- **Goal:** Replace the hardcoded `total = 400` constant and fixed 25/50/75% milestone markers in `ProgressBarView` with values derived live from `point_balance`, so the bar keeps producing meaningful milestones past 400 points.
- **Requirements:** R1
- **Dependencies:** none
- **Files:**
  - `CommitToIt/Views/ProgressBarView.swift`
- **Approach:** Add computed properties for `tier` (`floor(point_balance / 400)`), the tier's floor and cap (`tier*400`, `tier*400 + 400`), the three milestone values (`tier*400 + 100/200/300`), and within-tier `progress` (the balance's fraction between the tier's floor and cap). Replace every literal use of `total` — the fill-width calculation and each of the three milestone circle/label computations — with these tier-relative values.
- **Patterns to follow:** The existing `circleColor(for:currentProgress:)` helper and the `GeometryReader`-based percent positioning already used for the three milestone markers.
- **Test scenarios:**
  - Happy path: balance at 250 (tier 0) shows milestones 100/200/300, cap 400, ~62% fill.
  - Boundary: balance at exactly 400 computes tier 1 (milestones 500/600/700), not tier 0 at 100% fill.
  - Boundary: balance at 0 computes tier 0, milestones 100/200/300, 0% fill.
  - Higher tier: balance at 900 computes tier 2, milestones 900/1000/1100, cap 1200, 25% fill within the tier.
- **Verification:** In an Xcode Preview (or the simulator) with `AppState` seeded at each balance above, confirm the displayed point total, milestone labels, cap, and fill percentage match the expected tier math.

### U2. Directional level-up animation and no-flash fill

- **Goal:** Animate the milestone labels with an odometer-style roll specifically when `point_balance` crosses upward into a new tier; update them instantly on a downward crossing or on the view's initial render; and keep the fill bar from visually resetting during a crossing.
- **Requirements:** R2, R3, R4
- **Dependencies:** U1
- **Files:**
  - `CommitToIt/Views/ProgressBarView.swift`
- **Approach:** Initialize `displayedTier` from the current tier once, with no animation, when the view first appears. React to changes in `appState.user_stats.point_balance`: when the newly computed tier is greater than `displayedTier`, update `displayedTier` inside `withAnimation` so the milestone labels' `.contentTransition(.numericText())` performs the roll; when the newly computed tier is less than `displayedTier`, update it directly with no animation. Milestone labels and the fill width read from `displayedTier` (paired with the live `point_balance` for in-tier fraction) rather than the always-live tier, so a crossing updates deliberately instead of animating through an intermediate state.
- **Technical design** (directional, not implementation-literal):
  ```
  on first appearance:
    displayedTier = currentTier   // no animation

  on point_balance change:
    newTier = floor(point_balance / 400)
    if newTier > displayedTier:
      withAnimation { displayedTier = newTier }   // odometer roll
    else if newTier < displayedTier:
      displayedTier = newTier                     // instant, no roll
    // fill width recomputed from displayedTier + point_balance;
    // no forced spring animation on the crossing frame itself
  ```
- **Patterns to follow:** The existing `.animation(.spring(), value:)` usage on the fill and milestone circles for in-tier smoothness — that behavior is preserved for changes that don't cross a tier boundary.
- **Test scenarios:**
  - Covers AE1. Balance rises from 380 to 420, crossing 400 upward: milestones roll from 100/200/300 to 500/600/700; fill settles at ~5% within the new tier without visibly sweeping back down first.
  - Covers AE2. Balance drops from 550 to 300 via redemption, crossing 500 downward: milestones update instantly to 100/200/300 with no roll; fill shows 75% within tier 0.
  - Covers AE3. App launches with balance already at 900 (tier 2): on first appearance, milestones show 900/1000/1100 directly with no roll played.
  - Edge case: balance changes within the same tier (e.g., 150 to 200) — no tier-level roll triggers; only the existing spring-based fill/circle animation runs.
  - Edge case: balance crosses two tiers in a single update (e.g., 350 to 850, tier 0 to tier 2 in one task-completion response): the roll animates directly from the old tier's milestone values to the new tier's values, with no intermediate tier flash.
- **Verification:** In an Xcode Preview (or the simulator) driving `point_balance` through each scenario above — an increasing change crossing a boundary, a decreasing change crossing a boundary, an in-tier change, and a launch at a non-zero tier — confirm the roll, instant-update, and no-animation behaviors each match their scenario, and that the fill never visibly sweeps through a stale percentage during a crossing.

---

## Verification Contract

- No automated test target exists in this repo, so there is no `xcodebuild test` gate for this change. Use `xcodebuild -project CommitToIt.xcodeproj -scheme CommitToIt build` as the compile-gate command for both units.
- Behavioral verification for both units is manual, via Xcode Previews or the simulator, following the test scenarios listed in each unit above.

---

## Definition of Done

- `ProgressBarView` derives its milestones and fill from `point_balance` with no fixed 400-point cap (U1).
- Crossing a tier boundary upward rolls the milestone labels via `.contentTransition(.numericText())`; crossing downward or the view's initial render shows the new tier's milestones with no roll (U2).
- The fill bar does not visibly sweep through a stale percentage when a tier crossing occurs (U2).
- All test scenarios in U1 and U2 have been manually verified via Xcode Previews or the simulator.
- `xcodebuild -project CommitToIt.xcodeproj -scheme CommitToIt build` succeeds.
- No leftover experimental or dead-end code (e.g., an abandoned custom digit-roller attempt) remains in the diff.
