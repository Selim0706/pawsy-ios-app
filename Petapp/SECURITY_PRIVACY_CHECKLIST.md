# Security & Privacy Checklist (App Store Baseline)

## Implemented
- Photo library usage descriptions are configured in project build settings.
- No API keys or tokens are hardcoded in the app source.
- Pet customization persistence is isolated behind `PetSettingsStore`.
- Future secure storage interface is prepared via `KeychainService`.

## Required before production release
- Implement concrete Keychain service for sensitive values.
- Add privacy policy URL and in-app privacy section.
- Run release build scan for debug-only strings/logging.
- Perform dependency audit on every release candidate.

## Notes
- Current iteration is MVP Offline + Mock data.
- Backend auth and token handling are intentionally out of scope for this cycle.
