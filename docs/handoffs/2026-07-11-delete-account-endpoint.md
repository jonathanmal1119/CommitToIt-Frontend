---
title: Backend handoff — DELETE /user/delete-account
date: 2026-07-11
from: iOS client (CommitToIt.xcodeproj, branch app-store-compliance, commit 92dc3cf)
status: client implemented, backend endpoint does not exist yet
---

# Backend handoff: account deletion endpoint

## Why this is needed

Apple App Store Review Guideline **5.1.1(v)** requires that any app supporting
account creation must also let the user delete their account from within the
app. CommitToIt has signup but currently has no way to delete an account
anywhere — this is a near-certain App Store rejection as-is.

The iOS client has already been updated (branch `app-store-compliance`) to
call a new endpoint for this. It doesn't exist on the backend yet — that's
the work this doc hands off. The client also ships an in-app Privacy Policy
that now states account deletion is **"permanent"** and **"irreversible"**
(`CommitToIt/Views/PrivacyPolicyView.swift`), so the backend implementation
needs to actually hard-delete data, not soft-delete/deactivate — otherwise
the privacy policy claim becomes false.

## What the client sends

```
DELETE /api/user/delete-account
Host: api.committoit.click
Authorization: Bearer <accessToken>
Content-Type: application/json

{
  "user_id": 123
}
```

This matches the existing convention used by every other mutating endpoint
in this API (e.g. `POST /task/add-task`, `DELETE /task/delete-task`,
`POST /reward/purchase` all take a `user_id` in the JSON body alongside the
bearer token).

## What the client expects back

Swift decode target (`CommitToIt/Models/Auth.swift`):

```swift
struct DeleteAccountResponse: Decodable {
    let status: String
    let message: String
}
```

- Success: HTTP 200 with `{"status": "OK", "message": "..."}`. The client
  checks `status == "OK"`; anything else is treated as a failure and shown
  to the user as "Couldn't delete account. Please try again later."
- Any error response still needs to be valid JSON matching this same
  `{status, message}` shape (or a superset of it), or the client's
  `JSONDecoder` throws and the user sees the same generic failure message —
  which is fine functionally, but a distinct `message` still helps with
  support/debugging via logs.
- On success, the client immediately clears its local access/refresh tokens
  from Keychain and signs the user out (`AuthService.deleteAccount()` in
  `CommitToIt/Services/AuthService.swift`). It does **not** separately call
  `/user/logout` or anything else — the delete endpoint should be the only
  server round-trip.

## Critical security requirement

**Do not trust the `user_id` in the request body to decide whose account
gets deleted.** Derive the acting user from the authenticated bearer token
(same as whatever middleware already validates `Authorization: Bearer` on
other endpoints) and delete *that* user's account. Treat a mismatch between
the token's user and the body's `user_id` as a hard failure (401/403) rather
than silently using one or the other — an account-deletion endpoint is the
worst possible place to have an IDOR (insecure direct object reference)
bug, since the blast radius is a full, irreversible account wipe.

This same body-carries-`user_id` pattern already exists on the task/reward
endpoints (`/task/complete-task`, `/reward/redeem`, etc.) — if those aren't
already validating the token's user against the body's `user_id`, that's a
pre-existing IDOR worth fixing too, but this delete endpoint is the one
that must not ship without it.

## What "delete" needs to cover

Based on what the client reads/writes for a user (`TaskService`,
`RewardService`, `UserService`), a full account delete should remove:

- The user row itself (`users` table or equivalent).
- All of the user's tasks (whatever backs `GET /task?user_id=...`).
- All of the user's reward redemption history / earned rewards (whatever
  backs `GET /reward/user-rewards-history?user_id=...` — this is
  per-user data, distinct from the global `redeemable-rewards` catalog,
  which should **not** be touched).
- Any stored refresh tokens / active sessions for that user, so a
  previously-issued refresh token can't be used to mint a new access token
  after deletion (the client already clears its own copy, but the server
  side needs to invalidate it independently — the client can't be trusted
  to be the only place a token exists).
- Any other per-user server-side state (password reset tokens, push tokens,
  etc.) if those exist beyond what's visible from this client.

If any of this needs to happen in a specific order for FK constraints,
wrap it in a transaction so a partial failure doesn't leave an orphaned
user row or orphaned child rows.

## Edge cases to handle

- **Missing/expired/invalid token** → 401, matching whatever the other
  authenticated endpoints already return. The client's `APIClient` already
  does one automatic refresh-and-retry on a 401 for every request
  (`APIClient.request` in `CommitToIt/Services/APIService.swift`), so this
  doesn't need special-casing beyond normal auth middleware.
- **`user_id` that doesn't exist / already deleted** → return a clean error
  rather than a 500; the client shows a generic failure message either way,
  but clean errors matter for your own logs/debugging.
- **Concurrent requests** (e.g. double-tap before the button disables) →
  deleting an already-deleted user should fail gracefully, not throw an
  unhandled exception.

## Suggested endpoint signature (Express, matching existing route style)

```js
// DELETE /api/user/delete-account
router.delete('/delete-account', authenticate, async (req, res) => {
  const authenticatedUserId = req.user.id; // from verified JWT, not req.body
  // ... transaction: delete tasks, reward history, sessions/refresh tokens, then the user row ...
  res.json({ status: 'OK', message: 'Account deleted' });
});
```

Adjust to match whatever auth middleware / ORM this project already uses —
this is illustrative, not prescriptive.

## Testing checklist for the backend agent

- [ ] Valid token + matching `user_id` → 200, account and all owned rows
      gone from the DB, previously-issued refresh token for that user no
      longer works.
- [ ] Valid token but `user_id` in body belongs to a *different* user →
      rejected (401/403), no rows deleted.
- [ ] No/expired token → 401, no rows deleted.
- [ ] Deleting the same account twice → second call fails cleanly, doesn't
      500.
- [ ] After deletion, `POST /user/login` with that account's old
      credentials fails (account genuinely gone, not just flagged).

## Reference: existing endpoint conventions this should match

For a backend agent without access to the iOS repo, here's the full set of
endpoints the client currently calls against `https://api.committoit.click/api`,
for pattern consistency:

| Method | Path | Body | Response `data` |
|---|---|---|---|
| POST | `/user/login` | `{email, password}` | `{user_id, email, username, accessToken, refreshToken}` |
| POST | `/user/signup` | `{email, password, username}` | same shape as login |
| POST | `/user/refresh` | `{refreshToken}` | top-level `accessToken` (no `data` wrapper) |
| GET | `/user/user-stats?user_id=` | — | `{point_balance, completed_tasks, redeemed_rewards, total_points_earned}` |
| GET | `/task?user_id=&filter=` | — | `[TaskItem]` |
| POST | `/task/add-task` | `{user_id, title, description, point_value, due_date}` | `[TaskItem]` |
| POST | `/task/complete-task` | `{user_id, task_id}` | — (checked via `status == "OK"`) |
| DELETE | `/task/delete-task` | `{user_id, task_id}` | — (checked via `status == "OK"`) |
| POST | `/task/update-task` | `{user_id, task_id, title, description, due_date}` | `TaskItem` |
| GET | `/reward/redeemable-rewards` | — | `[PurchaseableReward]` (global catalog) |
| GET | `/reward/user-rewards-history?user_id=` | — | `[UserReward]` (per-user) |
| POST | `/reward/purchase` | `{user_id, reward_id}` | `[UserReward]` |
| POST | `/reward/redeem` | `{user_id, user_reward_id}` | — (checked via `status == "OK"`) |
| **DELETE** | **`/user/delete-account`** | **`{user_id}`** | **— (this handoff)** |

All responses share a `{status, message, data?}` envelope; `status: "OK"`
signals success, anything else is treated as failure client-side.
