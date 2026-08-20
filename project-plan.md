# BookNook — Build Plan

## Phase 1 — Finish Static UI (Assignment 1)
- [ ] Two layouts for **orientation** (portrait vs landscape)
- [ ] Two layouts for **screen size** (phone vs tablet)
- [ ] One more "other component type" (overflow menu, sort dropdown, or bottom sheet)
- [x] Card
- [x] Scrollable list
- [x] Master/detail
- [x] Form (Register screen)
- [x] Micro-interaction (hero transition)

## Phase 2 — Make CRUD Real (In-Memory First)
- [ ] Add `LibraryEntry` model
- [ ] Add `ReadingLog` model
- [ ] Set up state management (Riverpod or Provider) with an in-memory list
- [ ] "Add to Library" actually adds an entry
- [ ] My Library screen reads from the real list
- [ ] Delete actually removes an entry
- [ ] "Log Pages" form actually creates a log
- [ ] Progress screen stats/chart update from real logs

## Phase 3 — Local Persistence (Hive)
- [ ] Add Hive + hive_flutter packages
- [ ] Annotate models with `@HiveType` / `@HiveField`
- [ ] Run `build_runner` to generate adapters
- [ ] Swap in-memory list for real Hive read/write
- [ ] Test: add an entry, restart app, confirm it persists

## Phase 4 — Real API + Offline Fallback
- [ ] Wire Open Library search into Discover screen
- [ ] Add bundled `offline_books.json` asset
- [ ] Implement offline fallback logic
- [ ] Add `connectivity_plus` check
- [ ] Show offline banner when disconnected

## Phase 5 — Firebase Auth
- [ ] Set up Firebase project
- [ ] Add `firebase_core` + `firebase_auth`
- [ ] Replace fake login delay with real `signInWithEmailAndPassword`
- [ ] Replace fake register delay with real `createUserWithEmailAndPassword`
- [ ] Handle auth errors (wrong password, email in use)
- [ ] Wire logout to `FirebaseAuth.instance.signOut()`

## Phase 6 — Device Capabilities
- [ ] Camera — attach photo to a library entry (`image_picker`)
- [ ] Geolocation — nearby libraries screen (`geolocator`)
- [ ] Accelerometer — shake for random book suggestion (`sensors_plus`)
- [ ] Confirm network connectivity feature is solid

## Phase 7 — Polish
- [ ] Check light/dark mode contrast is accessible
- [ ] Confirm consistent M3 type scale usage (no hardcoded font sizes)
- [ ] Remove any remaining placeholder/lorem ipsum content
- [ ] Test on a real device (not just emulator) — especially camera + shake

## Phase 8 — Testing
- [ ] Write test plan document (what/how tested, expected vs actual result)
- [ ] Manual test: rotate device
- [ ] Manual test: go offline
- [ ] Manual test: deny permissions
- [ ] Manual test: add/edit/delete each CRUD entity

## Phase 9 — Presentation Prep
- [ ] Rehearse 15-minute walkthrough against marking scheme
- [ ] Prepare answers for likely Q&A (state management choice, local storage choice, API choice)
- [ ] Practice full live demo end-to-end at least twice

---

## Suggested Commit Checkpoints
- `Add responsive layouts for orientation and screen size`
- `Implement working CRUD for library and reading logs`
- `Persist library and reading log data with Hive`
- `Connect Discover screen to Open Library API with offline fallback`
- `Add Firebase authentication for login and register`
- `Add camera, geolocation, and accelerometer features`