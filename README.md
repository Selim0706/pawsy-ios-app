# Pawsy iOS

English | Русский

Pawsy is a SwiftUI iOS pet care app built as an offline-first MVP with a soft bubble / glass visual style.

Pawsy — это iOS-приложение для ухода за питомцами на SwiftUI, собранное как offline-first MVP в мягком bubble / glass стиле.

Repository:
- [https://github.com/Selim0706/pawsy-ios-app](https://github.com/Selim0706/pawsy-ios-app)

## English

### Product Overview

Pawsy helps pet owners manage daily care, track pet wellness, keep medical reminders, switch between multiple pets, and use an offline AI assistant for basic safety guidance.

The app is designed for:
- daily pet care actions;
- health and mood tracking;
- reminders for vaccinations, vet visits, medications, and notes;
- multi-pet households;
- future partner integrations with vets and pet shops.

### Current Feature Set

#### 1. Dashboard
- soft UI home screen with health rings and hero pet presentation;
- working `Feed`, `Walk`, and `Play` actions;
- local pet state engine with cooldowns, mood, vitals, and daily progress;
- quick menu from the top-left dashboard button;
- Pawsy Hub sheet from the custom center Pawsy button;
- pet customization: name, style, accessory.

#### 2. Medical Hub
- custom calendar screen;
- user-created reminders instead of static placeholder banners;
- reminder categories: vaccination, vet visit, medication, grooming, note;
- reminder completion and deletion;
- visual day markers on calendar days with reminders;
- nearby services section prepared for future vet and pet shop partners.

#### 3. AI Assistant
- offline-first AI chat experience;
- local text safety heuristics through `VetRuleEngine`;
- photo attachment flow through `PhotosPicker`;
- local chat history persistence;
- animated hidden tab bar on chat screen for better focus.

#### 4. Profile & Community
- multiple pets support;
- active pet switching;
- map-based community area;
- add new pet flow;
- app settings entry point.

#### 5. Onboarding
- first-launch welcome flow;
- optional sign-in step UI;
- step-by-step pet registration instead of one long form;
- add-pet flow reused from onboarding logic.

#### 6. Settings
- theme mode: System / Light / Dark;
- reminders toggle;
- haptics toggle;
- clear chat history action.

### Design Direction

The UI direction is:
- soft UI / neumorphic / bubble-like surfaces;
- pastel mint / cream / peach / blue palette;
- rounded SF-style typography;
- custom tab bar with central Pawsy pill;
- branded splash and in-app identity.

### Current Technical Status

Implemented and working:
- SwiftUI app shell;
- offline MVP logic;
- local persistence for pet profiles, pet state, reminders, map region, and chat history;
- build passes in Xcode;
- unit tests pass.

Still in progress:
- full pixel-perfect polish across all screens;
- removal of remaining UX inconsistencies;
- real backend/auth/subscription integrations;
- real partner data and location-based search;
- final UI smoke test stabilization in simulator infrastructure.

### Architecture

Main source of truth:
- `/Volumes/MacSSDpro/Developer/Petapp/Petapp`

Main layers:
- `App/` — entry point, router, root container;
- `DesignSystem/` — colors, typography, styles, shapes;
- `Components/` — reusable UI components;
- `Features/` — Dashboard, Medical Hub, AI Assistant, Profile;
- `Models/` — domain models and app types;
- `Data/` — mock repository and local stores;
- `PetappTests/` — unit tests;
- `PetappUITests/` — UI tests.

Core flow:
- `AppRouter` controls active tab, sheet navigation, and tab bar visibility;
- feature view models own UI state and interact with local stores;
- the app is offline-first and does not require a backend to demo core flows.

### Quick Start

1. Open the Xcode project:
   - `/Volumes/MacSSDpro/Developer/Petapp/Petapp.xcodeproj`
2. Select scheme:
   - `Petapp`
3. Choose a simulator:
   - for example `iPhone 17 Pro`
4. Run:
   - `Cmd+R`

### Running Tests

In Xcode:
- `Product` -> `Test`

CLI examples:

```bash
cd /Volumes/MacSSDpro/Developer/Petapp
xcodebuild -project Petapp.xcodeproj -scheme Petapp -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
xcodebuild -project Petapp.xcodeproj -scheme Petapp -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

### Important Notes

- The app is intentionally built as an offline MVP first.
- Some archived prototype material still exists in the repository for reference.
- Active development should stay inside:
  - `/Volumes/MacSSDpro/Developer/Petapp/Petapp`

Archived / non-source-of-truth material:
- `*.legacy`
- `/Volumes/MacSSDpro/Developer/Petapp/UI/PawsyApp`

### Security / Privacy

- See:
  - `/Volumes/MacSSDpro/Developer/Petapp/Petapp/SECURITY_PRIVACY_CHECKLIST.md`
- Photo library related usage is already prepared for the app target.
- Future secrets or tokens should go to Keychain-based storage, not `UserDefaults`.

### Recommended Next Steps

1. finish the remaining visual polish for Dashboard, Medical Hub, and Profile;
2. replace any remaining default-feeling UI with branded bubble controls;
3. add local notifications for reminders;
4. expand pet profile editing and medical history;
5. connect real partner data, vets, and pet shop search;
6. prepare production auth and subscription flows.

---

## Русский

### Описание продукта

Pawsy помогает владельцам питомцев управлять ежедневным уходом, отслеживать состояние животного, хранить медицинские напоминания, переключаться между несколькими питомцами и пользоваться офлайн AI-помощником для базовых советов по безопасности.

Приложение рассчитано на:
- ежедневные действия по уходу;
- отслеживание здоровья и настроения;
- напоминания о прививках, визитах к врачу, лекарствах и заметках;
- семьи с несколькими питомцами;
- будущую интеграцию партнёров: ветеринаров и зоомагазинов.

### Что уже реализовано

#### 1. Dashboard
- главный экран в мягком bubble UI стиле;
- рабочие действия `Feed`, `Walk`, `Play`;
- локальный state engine питомца с cooldown, vitals, mood и daily progress;
- быстрое меню по кнопке слева сверху;
- `Pawsy Hub` по центральной кнопке `Pawsy`;
- настройка питомца: имя, стиль, аксессуар.

#### 2. Medical Hub
- кастомный экран календаря;
- пользователь сам создаёт напоминания, вместо старых статичных заглушек;
- категории напоминаний: vaccination, vet visit, medication, grooming, note;
- выполнение и удаление напоминаний;
- маркеры дней с напоминаниями;
- блок nearby services как подготовка к будущим партнёрам.

#### 3. AI Assistant
- офлайн AI-чат;
- локальная логика анализа текста через `VetRuleEngine`;
- прикрепление фото через `PhotosPicker`;
- локальное сохранение истории сообщений;
- скрытие tab bar на экране чата для более чистого UX.

#### 4. Profile & Community
- поддержка нескольких питомцев;
- переключение активного питомца;
- community map;
- добавление нового питомца;
- вход в настройки приложения.

#### 5. Onboarding
- приветственный сценарий первого запуска;
- UI-шаг с авторизацией, который можно пропустить;
- пошаговая регистрация питомца вместо одного длинного списка;
- логика onboarding переиспользуется и для добавления нового питомца.

#### 6. Settings
- тема: System / Light / Dark;
- переключатель reminders;
- переключатель haptics;
- очистка истории чата.

### Дизайн-направление

Визуальный стиль приложения:
- soft UI / neumorphism / bubble surfaces;
- пастельная палитра mint / cream / peach / blue;
- округлая типографика в стиле SF;
- кастомный tab bar с центральной кнопкой `Pawsy`;
- брендированный splash screen и внутренняя айдентика.

### Текущее техническое состояние

Уже работает:
- SwiftUI shell приложения;
- offline MVP логика;
- локальное сохранение профилей питомцев, состояния питомца, reminders, карты и истории чата;
- проект собирается в Xcode;
- unit tests проходят.

В процессе:
- полировка UI до более точного визуального уровня;
- устранение оставшихся UX-несовпадений;
- реальные backend/auth/subscription интеграции;
- реальные данные партнёров и геопоиск;
- финальная стабилизация UI smoke tests на уровне симулятора.

### Архитектура

Главный source of truth:
- `/Volumes/MacSSDpro/Developer/Petapp/Petapp`

Основные слои:
- `App/` — точка входа, router, root container;
- `DesignSystem/` — цвета, шрифты, стили, shapes;
- `Components/` — переиспользуемые UI-компоненты;
- `Features/` — Dashboard, Medical Hub, AI Assistant, Profile;
- `Models/` — доменные модели и типы;
- `Data/` — mock repository и local stores;
- `PetappTests/` — unit tests;
- `PetappUITests/` — UI tests.

Основной поток данных:
- `AppRouter` управляет вкладками, sheet-навигацией и видимостью tab bar;
- view model каждого экрана хранит состояние UI и работает с локальными store;
- приложение изначально построено как offline-first, без необходимости в backend для демонстрации.

### Быстрый запуск

1. Открой проект:
   - `/Volumes/MacSSDpro/Developer/Petapp/Petapp.xcodeproj`
2. Выбери схему:
   - `Petapp`
3. Выбери симулятор:
   - например `iPhone 17 Pro`
4. Запусти:
   - `Cmd+R`

### Запуск тестов

В Xcode:
- `Product` -> `Test`

Через CLI:

```bash
cd /Volumes/MacSSDpro/Developer/Petapp
xcodebuild -project Petapp.xcodeproj -scheme Petapp -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
xcodebuild -project Petapp.xcodeproj -scheme Petapp -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

### Важные замечания

- Приложение специально строится сначала как offline MVP.
- В репозитории ещё есть архивные материалы и старые прототипы для справки.
- Активную разработку нужно вести только в:
  - `/Volumes/MacSSDpro/Developer/Petapp/Petapp`

Архивные / неактуальные материалы:
- `*.legacy`
- `/Volumes/MacSSDpro/Developer/Petapp/UI/PawsyApp`

### Security / Privacy

- См.:
  - `/Volumes/MacSSDpro/Developer/Petapp/Petapp/SECURITY_PRIVACY_CHECKLIST.md`
- Использование Photo Library уже подготовлено для app target.
- Будущие токены и чувствительные данные нужно хранить через Keychain, а не `UserDefaults`.

### Что логично делать дальше

1. довести визуальную полировку Dashboard, Medical Hub и Profile;
2. заменить все оставшиеся стандартно выглядящие элементы на branded bubble controls;
3. добавить локальные уведомления для reminders;
4. расширить редактирование профиля питомца и medical history;
5. подключить реальные данные партнёров, ветеринаров и зоомагазинов;
6. подготовить production-авторизацию и подписку.

