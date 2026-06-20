# ☀️ Solstice Engine: A Turing Machine of Light & Shadow 🌙

Welcome to **Solstice Engine**, an interactive, responsive, and highly visual puzzle game built with **Flutter (Web PWA & Android)** for the June Solstice Hackathon.

The game is a dual celebration of the **June Solstice (June 21)** and the father of modern computing, **Alan Turing**, beautifully packaged with an **embedded Google Gemini AI companion sidebar** that serves as an algorithmic advisor to help players break the Solstice Ciphers.

---

## 🎮 Play & Concept
On June 21, the Earth experiences its solstice: the longest day of the year in the Northern Hemisphere, and the shortest (longest night) in the Southern Hemisphere. 

In **Solstice Engine**, the 24 hours of the day are represented as a **circular closed-loop Turing Machine tape** of 24 sectors.
- **☀️ Light / Day** is represented by binary symbol **1** (glowing golden-yellow).
- **🌙 Dark / Night** is represented by binary symbol **0** (cold deep-blue).

Your mission is to **program the Turing Machine's State Transition Table** (the instruction rules) so that when you run the Solstice Engine, the mechanical read/write arm (the astronomical clock hand) sweeps around the dial, read/writing symbols and transitioning states, until it halts in a configuration that perfectly matches the solstice targets!

---

## 🏛️ Level Design & Challenges
1. **Level 1: Summer Solstice (North):** The tape starts entirely Dark (0). Program the machine to write exactly **16 Light cells** representing the extended summer daylight hours in the North, and then transition to **HALT (H)** in under 40 steps.
2. **Level 2: Winter Solstice (South):** The tape starts entirely Light (1). Cleanse the tape to result in exactly **8 Light cells** and **16 Dark cells** (representing the winter night), then Halt in under 50 steps.
3. **Level 3: The Equinox Balance:** The tape starts in a chaotic scrambled pattern. Write a program to bring absolute equilibrium: exactly **12 Light and 12 Dark cells**, then Halt.
4. **Level 4: Turing's Solstice Enigma:** Break a complex block cipher: transform a blank tape into a precise, contiguous block pattern of **8 Light, 8 Dark, and 8 Light** cells in under 80 steps.

---

## 🎖️ Prize Categories Alignment

### 1. 🧬 Ode to Alan Turing
This game is a pure, interactive, and educational tribute to Alan Turing's groundbreaking work in both theoretical and practical computation:
* **The Interface IS a Turing Machine:** Unlike traditional games that simply mention Turing, *Solstice Engine* lets the player directly interact with and program a physical Turing Machine. The 24-hour cycle is a circular infinite tape, the state register is a glowing steampunk vacuum tube dial, and the rules are the state transition functions.
* **The Enigma / Bombe Aesthetic:** The UI mimics Bletchley Park code-breaking panels with mechanical ticking animations, vacuum tubes, glowing wires, and rotating astronomical gears.
* **Active State Glow:** When running the machine, the currently active transition rule corresponding to `(currentState, readSymbol)` glows with neon borders, making the debugging of Turing programs intuitive and engaging.

### 2. 🧠 Google AI Usage (Gemini API & Antigravity)
Google AI was leveraged throughout the lifecycle of this project:
* **Antigravity CLI & Gemini:** The entire scaffolding, coding, bidi layout optimization, compile troubleshooting (resolving Flutter canvas rendering differences), and packaging of this project were done autonomously in a private sandbox controlled by the **Antigravity CLI (`agy`)** and **Gemini Flash**.
* **Embedded Gemini AI Chat Helper:** The game features a built-in **Alan Turing & Gemini AI sidebar**. Players can ask the hybrid AI chat assistant for live level hints, deep-dive explanations of Turing machines, or the astronomical science behind the June Solstice.
* **Procedural Level Hint Engine:** The sidebar dynamically recognizes the current active level and uses prompt engineering templates to supply tailored algorithmic hints to help players solve the specific puzzle.

---

## 🛠️ How to Build & Run

### Prerequisites
* Flutter SDK (Channel Stable, ^3.12.0)
* Dart SDK

### Step 1: Run Locally
To run the game on your desktop, browser, or connected simulator:
```bash
cd solstice_turing_game
flutter run
```

### Step 2: Build for Web (PWA)
To compile a highly optimized, progressive web app (PWA) build:
```bash
flutter build web --release
```
The compiled files are generated under `build/web/` and are fully ready to be hosted on **GitHub Pages**, **Vercel**, or **Google Cloud Run**!

---

## 📂 Project Architecture
* `lib/models.dart` — Core models defining `TransitionRule` and the dynamic verification conditions for `GameLevel`.
* `lib/game_provider.dart` — The state machine simulation engine. Drives the step-by-step tape execution, speed controls, win-state evaluators, and the hybrid AI chat hint logic.
* `lib/main.dart` — Responsive game UI. Implements high-performance custom drawing via `CustomPainter` to draw the 24-hour clock face, Earth’s axial tilt ($23.5^\circ$), glowing state orbs, and the retro-steampunk control panels.

---
*Built with ❤️ in celebration of light, shadow, and the algorithms that balance them.*
