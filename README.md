# HopeOS

A personal life operating system designed especially for people with ADHD.

## Philosophy

HopeOS is not just a productivity tool. It is a personal life dashboard that helps users understand themselves and take small meaningful actions every day.

**Action-First Design**: When you open the app, the first thing shown is the next small action you can take. Statistics and data are secondary.

## Features

### Dashboard (Home)
- **Next Action Card** — prominently shows your most important pending action
- **Quick Actions** — 1-tap mood logging, water tracking, journal entry, and action creation
- **Daily Progress** — visual summary of actions, water, exercise, and mood
- **Pending Actions** — swipeable list with undo support

### Mental State Tracker
- Quick mood logging (1-5 scale with emoji)
- Energy level tracking (battery indicators)
- Optional notes per entry
- 7-day mood average
- Full history with swipe-to-delete + undo

### Physical Health
- **Water** — tap to add 100ml/250ml/500ml, progress ring, reset
- **Sleep** — slider input with goal tracking
- **Exercise** — add in 5/10/15/30 minute increments
- Weekly overview with progress bars

### Journal
- Quick-create new entries
- Autosave as you type (500ms debounce)
- Full-text search
- Swipe-to-delete with undo
- Title and content editing
- Entry count stats

### Settings
- User name personalization
- Theme switching (System/Light/Dark)
- Customizable daily goals (water, sleep, exercise)
- About section

## ADHD-Friendly Design

| Feature | Implementation |
|---------|---------------|
| Fast interaction | Every core action in 1-3 taps |
| Autosave | Journal autosaves every 500ms |
| Minimal friction | No confirmation dialogs for common actions |
| Undo for delete | 5-second undo snackbar on all deletes |
| Action-first | Dashboard shows next action prominently |
| Visual feedback | Progress rings, emoji, color-coded categories |

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter 3.x |
| Platforms | Android, iOS |
| State Management | Provider |
| Local Database | sqflite (SQLite) |
| Settings | SharedPreferences |
| Architecture | Feature-based modular |
| Design | Material 3 |

## Project Structure

```
hope_os/lib/
├── main.dart                    # App entry point
├── app_shell.dart               # Bottom navigation shell
├── core/
│   ├── constants/               # App-wide constants
│   ├── theme/                   # Material 3 theme
│   ├── utils/                   # Date utils, ID generator
│   └── widgets/                 # Reusable widgets (HopeCard, ProgressRing, etc.)
├── data/
│   ├── database/                # SQLite database helper
│   ├── models/                  # Data models (ActionItem, MoodEntry, etc.)
│   └── repositories/            # Data access layer with undo support
└── features/
    ├── actions/                 # Action management provider
    ├── dashboard/               # Home screen with action-first design
    │   └── widgets/             # NextActionCard, QuickActions, DailySummary
    ├── health/                  # Physical health tracking
    ├── journal/                 # Journal with autosave
    ├── mental/                  # Mood & energy tracking
    └── settings/                # App settings & goals
```

## Requirements

- Flutter 3.x
- Dart 3.x
- Android SDK 21+ / iOS 12+

## Setup

```bash
cd hope_os
flutter pub get
flutter run
```

## Architecture

- **Offline-first**: All data stored locally in SQLite via sqflite
- **Modular**: Each feature is self-contained with its own provider, screen, and widgets
- **Undo support**: Deleted items are stored in a `deleted_items` table for 5-second recovery
- **Autosave**: Journal entries save automatically with 500ms debounce
