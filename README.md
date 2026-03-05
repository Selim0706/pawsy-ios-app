# Petapp iOS (SwiftUI)

Готовый Xcode-проект для iPhone/iPad с экранами:
- Dashboard
- Medical Hub
- AI Assistant
- Profile & Community

## Быстрый запуск в Xcode

1. Откройте файл проекта:
   - `/Volumes/MacSSDpro/Developer/Petapp/Petapp.xcodeproj`
2. Выберите схему `Petapp`.
3. Выберите симулятор, например `iPhone 16 (iOS 18.4)`.
4. Нажмите `Run` (`Cmd+R`).

## Запуск тестов

- В Xcode: `Product` -> `Test` (`Cmd+U`)
- CLI:
  - `xcodebuild -scheme Petapp -project Petapp.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.4' test`

## Что внутри

- `Petapp/` — основной SwiftUI код приложения
- `PetappTests/` — unit tests
- `PetappUITests/` — UI tests
- `project.yml` — конфиг XcodeGen для пересоздания проекта

## Data Flow (Offline MVP)

- `AppRouter` управляет активной вкладкой и видимостью кастомного tab bar.
- `DashboardViewModel` использует `PetStateEngine` + `PetStateStore`:
  - действия `Feed/Walk/Play` меняют `PetState` и ring-метрики;
  - состояние питомца сохраняется локально между сессиями.
- `AIAssistantViewModel` использует:
  - `VetRuleEngine` (offline safety rules по тексту),
  - `ImageSafetyHeuristics` (локальные фото-эвристики),
  - `ChatHistoryStore` (история чата в local storage).

## Active Source Of Truth

- Активная реализация: `/Volumes/MacSSDpro/Developer/Petapp/Petapp`
- Архивные материалы:
  - `*.legacy` — historical snapshots
  - `/Volumes/MacSSDpro/Developer/Petapp/UI/PawsyApp` — prototype branch

## Security / Privacy

- См. `/Volumes/MacSSDpro/Developer/Petapp/Petapp/SECURITY_PRIVACY_CHECKLIST.md`
- Photo Library usage descriptions уже добавлены в build settings для app target.

## Пересоздать .xcodeproj (если нужно)

```bash
cd /Volumes/MacSSDpro/Developer/Petapp
xcodegen generate
```
