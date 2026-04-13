# HelpAI

A macOS SwiftUI chat app that integrates **AgentMLX** to run a local LLM on Apple Silicon.

---

## Requirements

| Tool | Version |
|------|---------|
| macOS | 14.0+ |
| Hardware | Apple Silicon (required for MLX) |
| Xcode | 15.0+ |
| SwiftPM | bundled with Xcode |

---

## 1. Open and run the app

### 1a. Open project in Xcode

Open the app project in Xcode from the `HelpAI` folder.

### 1b. Build and run

1. Select the `HelpAI` scheme.
2. Build with `⌘B`.
3. Run with `⌘R`.

---

## 2. Resolve package dependencies (CLI)

If Xcode does not resolve packages automatically, run:

```bash
cd HelpAI
xcodebuild -resolvePackageDependencies
```

For model configuration (download, folder structure, and setup), follow the instructions in `AgentMLX/README.md`.

---

## 3. Architecture overview

- App entry point creates and injects the main view model
- Main screen renders chat state and message timeline
- View model manages loading, generation, and error states
- Reusable UI components handle chat input and message rendering
- Localized strings are centralized in one place
- `AgentMLX` provides local model loading and inference

---

## 4. Runtime flow (AgentMLX integration)

On app launch (`MainViewModel.init`):

1. State starts at `.loadingModel`.
2. App reads `ModelSource.default`.
3. App creates an agent with `AgentMLX.create(modelSource:)`.
4. State switches to `.ready` on success or `.error(message)` on failure.

When user sends a prompt:

1. Input is trimmed and validated.
2. User message is appended to local `history`.
3. `agent.generate(with:)` runs asynchronously.
4. UI history is synchronized from `agent.history`.

---

## 5. Developer workflow

### Clean build folder

Use Xcode menu: `Product > Clean Build Folder` (`⇧⌘K`).

### Quick sanity checks

- App reaches `.ready` after launch
- Sending one prompt returns assistant response
- Error state is displayed when model loading fails

---

## 6. Troubleshooting

| Problem | Fix |
|---------|-----|
| Packages fail to resolve | Run `xcodebuild -resolvePackageDependencies` or `File > Packages > Resolve Package Versions` |
| Build fails after dependency changes | Clean build folder (`⇧⌘K`) and rebuild |
| App stuck on loading state | Verify local model source exists and AgentMLX loads without error |
| No assistant response | Check state is not `.generating` and inspect Xcode debug console |

---

## 7. Notes

- Model artifacts are intentionally excluded by the repository root `.gitignore`.
- Keep app/UI logic in `HelpAI` and model/inference logic in `AgentMLX`.

---

## 8. Related docs

- AgentMLX developer documentation — model setup and MLX integration details
