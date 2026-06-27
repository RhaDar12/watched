# Watched ✦

**Movie & Series Watch Log Diary** — built with Flutter.

Track every film and series you've watched, rate them, write personal notes, and build your own watch history library. Designed with a premium dark aesthetic — pure black (#0E0E0E) background with subtle spotlight effects and Montserrat typography.

## ✨ Features

- **Watch Log** — Add movies/series with title, rating, notes, and poster image
- **Local Database** — All data stored locally via SQLite/sqflite — no account needed
- **Image Picker** — Attach poster images from gallery or camera
- **Search & Filter** — Find entries quickly by title, genre, or status
- **Categories** — Organize by All, Film, or Series
- **Spotlight UI** — Smooth animations, gradient accent glow, and fade transitions
- **Dark Theme** — True black (#0E0E0E) with pure white text, full immersive mode
- **Auth Ready** — Login/Register screens with local authentication

## 🧱 Tech Stack

| Layer | Tech |
|-------|------|
| Framework | Flutter (Dart) |
| Local DB | SQLite via sqflite |
| State | setState + provider pattern |
| Font | Montserrat (variable weight) |
| Navigation | GoRouter + IndexedStack |
| Assets | Custom background, film-reel icon |

## 📁 Project Structure

```
lib/
├── main.dart                  # Entry point
├── app/
│   ├── app.dart               # App root widget
│   ├── router.dart            # GoRouter navigation
│   └── theme/
│       ├── app_theme.dart     # Theme config
│       ├── app_colors.dart    # Color palette
│       ├── app_typography.dart # Typography scale
│       └── app_dimensions.dart # Spacing & sizing
├── core/
│   ├── constants/
│   ├── utils/
│   └── widgets/
│       ├── bottom_nav_bar.dart # Animated tab bar
│       ├── app_widgets.dart   # Shared widgets
│       └── spotlight_background.dart # Background effect
├── data/
│   ├── database_helper.dart   # SQLite CRUD
│   ├── auth_service.dart      # Local auth logic
│   └── models/
│       ├── watched_item.dart  # Movie/series model
│       └── user.dart          # User model
└── features/
    ├── splash/
    ├── auth/                  # Login & Register
    ├── home/                  # Main feed — All/Film/Series tabs
    ├── add/                   # Add new entry
    ├── detail/                # Entry detail view
    ├── main/                  # Bottom nav scaffold
    └── profile/               # User profile
```

## 🚀 Getting Started

```bash
# Clone
git clone git@github.com:RhaDar12/watched.git
cd watched

# Install dependencies
flutter pub get

# Run
flutter run
```

Requires Flutter SDK `^3.11.5`.

## 🎨 Design

Designed in **Figma**, exported via Antigravity Figma-to-Flutter pipeline. Dark palette with accent spotlight glow and fluid motion design.

## 📄 License

MIT — feel free to use and modify.
