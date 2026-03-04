# Code Review & Multiplayer Planning — 4 March 2026

## Context

Coming back after a break. The single-screen game is functional: sliders appear, players can click them to reveal words, any player can press Guess and type an answer. The goal now is to move to a Jackbox-style experience where each player uses their mobile device as a controller.

---

## 1. What's Working Well

The foundation is solid. A lot of the right instincts are already in the code:

- **Signal-driven architecture** — `GameManager`, `PlayerManager`, and the UI communicate via signals, not direct references. 
- **Centralised state** — Game rules live in `GameManager`; player state lives in `PlayerManager`. Neither the UI scenes nor the round scenes hold canonical state.
- **State machine with validated transitions** — `GameManager._is_valid_transition()` prevents illegal jumps. A `LOBBY` state is already defined but unused — clearly this was planned ahead.
- **`device_id` on `Player`** — `Player.device_id` already exists and is accepted as an argument in `PlayerManager.add_player()`. This was clearly anticipated for networking. It just needs to be wired up.
- **`GameConfig`** — Constants centralised rather than scattered as magic numbers. `MIN_PLAYERS`/`MAX_PLAYERS`, difficulty multipliers, timing constants.
- **`QuestionLoader` and `Question` resource** — Clean data layer. Static loader, typed resource class, JSON-backed. Easy to extend.
- **`InputValidator`** — Validation class exists with `validate_player_name`, `validate_answer`, etc. Currently unused where it matters most (see issues below).

---

## 2. Code Review Issues

### 2.1 Turn Advancement — ✅ Not a Bug (2026-03-04)

**File:** `scenes/components/rounds/qna.gd` — `_on_slider_clicked()`  
**File:** `scripts/autoload/PlayerManager.gd` — `freeze_player()`

The two `next_turn()` call sites are on **mutually exclusive code paths** and do not double-fire:
- **Slider reveal**: `next_turn()` is called in `_on_slider_clicked` when a word tile is clicked. This is the only action on that turn — no guess can follow from the same interaction.
- **Wrong guess**: `freeze_player()` calls `next_turn()` internally after freezing the player.

A slider click and a guess are separate UI interactions; a player either reveals OR guesses, never both in the same flow. `GameManager.handle_wrong_answer()` even has a `# PlayerManager.next_turn()` commented out — correctly removed because `freeze_player()` already handles it.

### 2.2 Prize Deduction — ✅ Resolved (2026-03-04)

**File:** `scenes/components/rounds/qna.gd` — `_on_slider_clicked()`

The pot reduction (`current_prize = max(current_prize - prize_per_word, minimum_prize)`) has been re-enabled. Pot reduces on each non-blank slider reveal. Blank tiles do not reduce the pot and do not advance the turn.

### 2.3 `get_leaders()` — ✅ Resolved (2026-03-04)

**File:** `scripts/autoload/PlayerManager.gd`

The `highest_score = 1` was an intentional workaround to suppress the leader indicator before anyone has scored. Replaced with the explicit intent: find the real highest score across all players, then return an empty array if it is `<= 0`. This correctly shows no leader at the start of the game, shows the correct leader once someone scores, and handles ties.

### 2.4 `InputValidator` Not Used for Answer Matching

**File:** `scenes/components/rounds/qna.gd` — `_on_answer_submitted()`

`InputValidator.validate_answer()` exists but answer submission in `qna.gd` does its own bare string comparison. At minimum, `validate_answer()` should be called before emitting `round_result`. More importantly, the answer comparison itself could use fuzzy matching (see §2.5).

### 2.5 Answer Comparison Is Exact String Match Only

**File:** `scenes/components/rounds/qna.gd` — `_on_answer_submitted()`

```gdscript
var is_correct = answer_text.strip_edges().to_lower() == current_question.answer.strip_edges().to_lower()
```

This will fail for minor typos, extra spaces between words, or punctuation differences. For a party game where players type quickly on phones this will cause frustration. Even a simple "close enough" check (e.g., Levenshtein distance ≤ 1 or 2) would help significantly. `InputValidator` would be the right home for this.

### 2.6 Question Deduplication Uses Full Question Text as Key

**File:** `scripts/autoload/GameManager.gd` — `get_next_question()`

```gdscript
used_question_ids.append(next_q.question_text)
```

The `Question` resource has no `id` field. Deduplication uses the full question text string as the key. This is fragile — any whitespace or punctuation difference between the JSON and the comparison will cause re-use. The `Question` class should have a dedicated `id: String` field.

### 2.7 `ROUND_END` State Is Unused

**File:** `scripts/autoload/GameManager.gd`

The state machine defines `ROUND_END` and `_is_valid_transition()` handles it, but the game never enters it. The flow goes `IN_PROGRESS` → `IN_PROGRESS` (via `_start_next_round`). If you want to show a round summary screen or pause between rounds, this state is the hook. Currently it's dead code.

### 2.8 `Game.record_round_result()` Is Never Called

**File:** `scripts/classes/Game.gd`

`round_history` and `record_round_result()` are defined but nothing calls `record_round_result()`. History is never built. This is needed for any end-of-game summary, replays, or network state syncing.

### 2.9 `_recursive_set_focus` Uses Node Metadata for State Storage

**File:** `scenes/screens/game_board.gd`

Storing focus mode in node metadata (`set_meta("stored_focus_mode", ...)`) works but is fragile — if the node is freed between enable/disable calls, the metadata is lost. The same pattern appears in `answer_modal.gd`. This is fine for now but worth noting as a potential source of hard-to-reproduce bugs.

### 2.10 `game_init.gd` Doesn't Use `InputValidator`

**File:** `scenes/screens/game_init.gd`

Player count selection uses hardcoded buttons with metadata values — fine. But if/when player names are added (needed for multiplayer), `InputValidator.validate_player_name()` should be called there.

### 2.11 `player_picker` Component Exists But Is Unused

**File:** `scenes/components/player_picker.gd` / `player_picker.tscn`

This component exists but isn't referenced anywhere in the current flow. Unclear if it's a leftover from an earlier approach or planned for the lobby screen.

### 2.12 `main.gd` `_on_return_to_home` Is Defined But Not Connected in `load_game_init()`

**File:** `scenes/screens/main.gd` — `load_game_init()`

`_on_return_to_home` is connected as a callback from `game_init.back_to_home`, but the initial state transition in `_on_game_init_complete` does `GameManager.change_state(MENU)` → `change_state(SETUP)` which works, but if you return to home from `game_init` and then start again, the state machine may complain (MENU → SETUP is valid, but NONE → MENU must happen first via splash). Worth double checking the re-entry path.

---

## 3. Turn Model — ✅ Resolved (2026-03-04)

**Confirmed: Option A — Turn-Based (only current player acts)**

On their turn, the current player chooses **one** of:
- **Reveal a slider** — pot reduces, turn passes to next player
- **Submit a guess** — correct = round over; incorrect = frozen, turn passes

No other player can click sliders or guess out of turn. This is the answer to the multiplayer question "who can click sliders" — **only the current player's phone is interactive on any given turn**.

This simplifies the networking model considerably:
- The server only needs to accept input from the player whose turn it is
- All other clients show sliders as read-only until it's their turn
- `NetworkManager` can validate/reject out-of-turn messages server-side

~~The current single-screen game is ambiguous about who does what...~~ *(original ambiguity notes removed — model is confirmed)*

---

## 4. Multiplayer Architecture Plan

### 4.1 High-Level Approach (Jackbox Model)

```
[Host Device — big screen]          [Player Phones — browsers]
  Godot app                  <-->     Web page (or Godot web export)
  WebSocket server                    WebSocket clients
  Renders game state                  Renders player-specific UI
  Owns all game logic                 Send only input events
```

The host Godot app runs a WebSocket server. Players open a URL on their phones (e.g. `192.168.1.x:PORT` on local network, or a relay service for internet play). The phone UI is minimal: join screen, slider grid, guess input.

### 4.2 What Godot Provides

- `WebSocketServer` / `WebSocketPeer` (Godot 4 — use `WebSocketMultiplayerPeer` or raw `WebSocketServer`)
- `HTTPServer` (for serving the web client, or use a separate static server)
- Optionally: Godot web export for the client (same codebase, different export)

The simplest starting point is raw WebSocket messages (JSON strings). Later, you could move to Godot's high-level `MultiplayerAPI` but that's more complex.

### 4.3 New Autoload: `NetworkManager`

This would be a new autoload responsible for:

- Starting/stopping the WebSocket server
- Assigning connection IDs to `Player.device_id`
- Sending messages to specific clients or broadcasting
- Receiving messages and routing them as signals to game logic

```
NetworkManager signals (to game):
  client_connected(connection_id)
  client_disconnected(connection_id)
  slider_click_received(connection_id, slider_index)
  guess_received(connection_id, answer_text)
  player_ready_received(connection_id)

NetworkManager methods (from game):
  broadcast_game_state(state_dict)
  send_to_player(player_id, message_dict)
  broadcast_new_round(question_meta)   # NOT the answer!
  broadcast_slider_revealed(index)
  broadcast_turn_changed(player_id)
  broadcast_scores(scores_dict)
```

### 4.4 Protocol Messages

#### Server → Client
| Message Type     | Payload                                         | Notes                          |
|------------------|-------------------------------------------------|--------------------------------|
| `welcome`        | `{player_id, room_code}`                        | On connection                  |
| `lobby_state`    | `{players: [{id, name, color}]}`                | While in lobby                 |
| `game_start`     | `{game_type, game_target}`                      |                                |
| `new_round`      | `{round: int, slider_count: int}`               | **No question or answer!**     |
| `slider_revealed`| `{index: int, word: String, revealer_id}`       | Broadcast when any slider clicked |
| `turn_changed`   | `{player_id: String}`                           |                                |
| `guess_result`   | `{player_id, is_correct, prize, is_frozen}`     |                                |
| `round_end`      | `{answer: String, winner_id or null}`           | Reveal the answer to all       |
| `scores`         | `{players: [{id, name, score, is_frozen}]}`     |                                |
| `game_over`      | `{winner: {id, name, score}}`                   |                                |

#### Client → Server
| Message Type    | Payload                      | Notes                              |
|-----------------|------------------------------|------------------------------------|
| `join`          | `{room_code, player_name}`   | On load                            |
| `click_slider`  | `{index: int}`               | Player tapped a slider tile        |
| `submit_guess`  | `{answer: String}`           | Player submitted their answer      |
| `ready`         | `{}`                         | Player ready for next round        |

### 4.5 Changes to Existing Code

#### `Player.gd`
- `device_id` is already there ✅
- Add `is_connected: bool` for tracking live connections

#### `PlayerManager.gd`
- `add_player()` already accepts `device_id` ✅
- Add `get_player_by_device_id(device_id)` — currently only `get_player_by_id(player_id)` exists
- Player join flow: `NetworkManager` calls `PlayerManager.add_player(name, connection_id)` in lobby phase

#### `GameManager.gd`
- `LOBBY` state already defined ✅ — start_game flow needs to pass through it
- `start_game()` currently creates players itself from a count. For multiplayer, players are created during lobby (via `NetworkManager` signals). The `start_game()` call should be a "begin the game" signal rather than also creating players.

#### `game_init.gd` / lobby screen
- Instead of: "select number of players"
- Becomes: host picks settings, starts lobby, room code is displayed
- Players join from their phones, names appear on screen
- Host presses Start when everyone is in

#### `qna.gd` (round scene)
- Currently handles all input directly
- Needs to be decoupled from direct `_gui_input` for slider clicks: clicks come in as `NetworkManager` signals, not UI events
- The slider grid on the main screen becomes read-only / display-only — it just shows reveals as they happen
- The `answer_modal` is replaced by a "waiting for guess" state — the guess comes from the phone

#### `slider.gd`
- For the main screen: remove click handling, just `reveal()` when told to by the game
- The mobile client has its own slider UI (simpler — buttons, not the animated panel)

### 4.6 Lobby Screen (New)

This is the missing piece. Needs:
- Room code display (e.g. 4-letter code from `GameIdGenerator`)
- QR code or URL for players to open on phones
- Live player list as people join (connected to `NetworkManager.client_connected`)
- "Start Game" button (only host can press)
- Player name editing (or names come from phone join form)

### 4.7 Client Web App

Minimal viable client (could be Godot web export or plain HTML/JS):
- Join screen: text field for room code and player name
- Waiting screen: "Waiting for game to start…" with player list
- Game screen: 3×3 grid of numbered tiles (or just numbers if not revealed yet)
- Active state: tap tile → sends `click_slider`; "Guess!" button → text input → sends `submit_guess`
- Frozen state: greyed out, can't interact
- Round end: shows answer, score update, "Ready" button

---

## 5. Suggested Next Steps (Ordered)

### Step 1: Clarify the Game Rules
Before writing a line of networking code, write down exactly:
- Who can click sliders? (current player only, any active player, any player)
- Can frozen players see sliders on their device? Can they interact?
- Is the Guess button available to any player or only the current player?
- What does a player see on their phone vs. what the main screen shows?

Write this in `02-technical/Game Rules.md` — it looks like that file exists but may need updating.

### Step 2: Fix the Known Bugs
These are quick wins that should happen before the multiplayer work:
- Fix `get_leaders()` score-zero bug (`highest_score = 0`)
- Add a `id` field to `Question` and use it for deduplication
- Decide whether to re-enable or permanently remove the prize deduction (and document why)
- Wire up `InputValidator.validate_answer()` in `qna.gd`

### Step 3: Decouple Input from `qna.gd`
The round scene currently *receives* input events directly. Refactor so it *reacts to signals*:
- Extract slider-click handling into a signal `slider_requested(index)` that can be emitted by either local UI or NetworkManager
- Extract guess submission into a signal `guess_submitted(answer)` similarly
This makes local play and networked play use the same code path.

### Step 4: Build `NetworkManager` (Stub First)
Create `scripts/autoload/NetworkManager.gd` with the interface (signals and methods) defined but stubs for the actual WebSocket code. The game can use `NetworkManager` signals in local mode too — they'd just be emitted locally. This is the "adapter" pattern — the game doesn't know whether it's networked or not.

### Step 5: Build the Lobby Screen
New scene: `scenes/screens/lobby.gd` + `.tscn`
- Display room code and QR/URL
- Live player list via `NetworkManager.client_connected`
- Start button connects to `GameManager.start_game()`
Plug it into `main.gd` after `game_init`.

### Step 6: Build the Mobile Client
Start with a Godot web export of a minimal "client" scene. This can be a separate set of scenes within the same project (exported differently) or a separate project.

---

## 6. Architecture Diagram

```
main.gd (scene manager)
  │
  ├── SplashScreen
  ├── GameHome  
  ├── GameInit (settings)
  ├── Lobby (NEW) ◄── NetworkManager.client_connected
  ├── GameBoard
  │     ├── HUD (badges, controls)
  │     └── RoundArea
  │           └── QnA (round scene)
  │                 ├── SliderGrid (display only in MP)
  │                 └── GuessArea (display only in MP - input comes from phone)
  └── GameEnd

Autoloads:
  GameManager   ← owns state machine and game rules
  PlayerManager ← owns player list and turns
  GameConfig    ← constants
  NetworkManager (NEW) ← owns WebSocket server, routes messages
```

---

## 7. Files to Read Before Next Session

- `nutshell-knockoff-docs/02-technical/Game Rules.md` — needs to be updated with multiplayer rules
- `nutshell-knockoff-docs/02-technical/Networking Architecture.md` — likely a placeholder, needs the above plan fleshed out
- `nutshell-knockoff-docs/02-technical/Player Management.md` — check if lobby/join flow is documented
