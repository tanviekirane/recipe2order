# Recipe2Order

Plan your week's recipes and generate a consolidated shopping list for easy grocery ordering!

## Features

- **Recipe Input** - Add recipes via text input or URL import
- **URL Import** - Paste a recipe URL from popular cooking sites to auto-extract ingredients
- **Smart Parsing** - Automatic extraction of ingredients with quantities and units
- **Recipe Management** - View, edit, and delete saved recipes
- **Shopping Lists** - Create aggregated shopping lists from multiple recipes
- **Ingredient Aggregation** - Automatically combines same ingredients across recipes (e.g., 2 cups flour + 1 cup flour = 3 cups flour)
- **Progress Tracking** - Check off items as you shop with visual progress indicators
- **Share & Export** - Copy to clipboard or share lists via any app
- **Dark Mode** - Full light/dark theme support

## How to Use

### Adding a Recipe

1. **Navigate to Recipes** - Tap the "Recipes" tab in the bottom navigation bar
2. **Add New Recipe** - Tap the "Add Recipe" button (FAB)
3. **Enter Recipe Text** - Paste or type your recipe ingredients:
   ```
   Chicken Curry

   2 cups rice
   1 lb chicken breast
   2 tbsp olive oil
   1 onion, diced
   3 cloves garlic, minced
   ```
4. **Parse Recipe** - Tap "Parse Recipe" to extract ingredients
5. **Review & Edit** - Review the parsed ingredients, edit quantities/units if needed
6. **Save** - Tap "Save" to add the recipe to your collection

### Importing a Recipe from URL

1. **Navigate to Recipes** - Tap the "Recipes" tab
2. **Add New Recipe** - Tap the "Add Recipe" button
3. **Select "From URL" Tab** - Switch to the URL import tab
4. **Paste URL** - Paste a recipe URL from sites like AllRecipes, Food Network, Epicurious, etc.
5. **Fetch Recipe** - Tap "Fetch Recipe" to automatically extract ingredients
6. **Review & Save** - Review the parsed ingredients and save

### Managing Recipes

- **View Recipe** - Tap any recipe card to see its details
- **Edit Recipe** - Tap the pencil icon to modify title or ingredients
- **Delete Recipe** - Tap the delete icon with confirmation

### Creating a Shopping List

1. **Navigate to Shopping Lists** - Tap the "Lists" tab
2. **Create New List** - Tap "Create List" button
3. **Name Your List** - Enter a name (e.g., "Week of Jan 13")
4. **Select Recipes** - Check the recipes you want to shop for
5. **Create** - Tap "Create List" to generate your aggregated shopping list

### Shopping with Your List

1. **Open List** - Tap a shopping list card to view items
2. **Check Items** - Tap checkboxes as you add items to your cart
3. **Track Progress** - Watch the progress bar fill as you shop
4. **Quick Actions** - Use the menu (three dots) for:
   - Rename list
   - Check/uncheck all items
   - Clear checked items
   - Delete list

### Sharing Your List

- **Copy to Clipboard** - Tap the copy icon to copy as formatted text
- **Share** - Tap the share icon to send via messaging apps, email, etc.

## Customer Journey

```
┌─────────────────────────────────────────────────────────────┐
│                     RECIPE2ORDER                            │
│                    Customer Journey                         │
└─────────────────────────────────────────────────────────────┘

    ┌──────────┐     ┌──────────┐     ┌──────────┐
    │  HOME    │────▶│ RECIPES  │────▶│  ADD     │
    │  SCREEN  │     │  LIST    │     │  RECIPE  │
    └──────────┘     └──────────┘     └──────────┘
         │                │                 │
         │                │                 ▼
         │                │           ┌──────────┐
         │                │           │  PARSE   │
         │                │           │  TEXT    │
         │                │           └──────────┘
         │                │                 │
         │                ▼                 ▼
         │           ┌──────────┐     ┌──────────┐
         │           │  RECIPE  │◀────│  REVIEW  │
         │           │  DETAIL  │     │  EDIT    │
         │           └──────────┘     └──────────┘
         │
         ▼
    ┌──────────┐     ┌──────────┐     ┌──────────┐
    │ SHOPPING │────▶│  CREATE  │────▶│   LIST   │
    │  LISTS   │     │   LIST   │     │  DETAIL  │
    └──────────┘     └──────────┘     └──────────┘
                                           │
                                           ▼
                                      ┌──────────┐
                                      │  SHARE   │
                                      │  EXPORT  │
                                      └──────────┘
```

### Typical User Flow

1. **First Visit** - User sees welcome screen with quick action cards
2. **Add Recipes** - User adds 2-3 recipes for the week
3. **Create List** - User selects recipes and creates shopping list
4. **Go Shopping** - User checks off items while at the store
5. **Share (Optional)** - User shares list with family members

## Screenshots

The app features a clean Material Design 3 interface with:
- Bottom navigation for easy access to Home, Recipes, and Lists
- Card-based layouts for recipes and shopping lists
- Progress indicators showing shopping completion
- Checkboxes with strikethrough styling for checked items

## Prerequisites

Before running this app, ensure you have the following installed:

### 1. Flutter SDK
- **Version:** 3.38.x or later
- **Installation:** https://docs.flutter.dev/get-started/install

Verify installation:
```bash
flutter --version
```

### 2. For Android Development
- **Android Studio** with Android SDK
- **Android Emulator** or physical device with USB debugging enabled
- Run `flutter doctor` to verify Android toolchain

### 3. For iOS Development (macOS only)
- **Xcode** (latest version from App Store)
- **CocoaPods:** `sudo gem install cocoapods`
- Run `flutter doctor` to verify Xcode installation

## Getting Started

### 1. Clone the repository
```bash
git clone <repository-url>
cd recipe2order
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run the app

#### Option A: Using VS Code (Recommended)
1. Open the project in VS Code
2. Install the "Flutter" extension if not already installed
3. Select a device from the bottom status bar
4. Press `F5` or go to Run > Start Debugging

#### Option B: Using Command Line

**Check available devices:**
```bash
flutter devices
```

**Run on Android Emulator:**
```bash
# Start an emulator first (if not running)
flutter emulators --launch <emulator_id>

# Run the app
flutter run
```

**Run on iOS Simulator (macOS only):**
```bash
# Open iOS Simulator
open -a Simulator

# Run the app
flutter run
```

**Run on Connected Physical Device:**
```bash
flutter run -d <device_id>
```

### 4. Hot Reload & Hot Restart
- **Hot Reload:** Press `r` in terminal (or save file in IDE) - preserves state
- **Hot Restart:** Press `R` in terminal - resets state

## Development Commands

```bash
# Analyze code for issues
flutter analyze

# Run tests
flutter test

# Build APK (Android)
flutter build apk

# Build iOS (macOS only)
flutter build ios

# Clean build artifacts
flutter clean
```

## Project Structure

```
recipe2order/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/
│   │   ├── ingredient.dart          # Ingredient data model
│   │   ├── recipe.dart              # Recipe data model
│   │   ├── list_item.dart           # Shopping list item model
│   │   └── shopping_list.dart       # Shopping list model
│   ├── providers/
│   │   ├── recipe_provider.dart     # Recipe state management
│   │   ├── shopping_list_provider.dart  # Shopping list state
│   │   └── theme_provider.dart      # Theme state management
│   ├── screens/
│   │   ├── app_shell.dart           # Main navigation container
│   │   ├── home_screen.dart         # Welcome & quick actions
│   │   ├── recipes_screen.dart      # Recipe list view
│   │   ├── recipe_detail_screen.dart    # Single recipe view
│   │   ├── add_recipe_screen.dart   # Add new recipe
│   │   ├── edit_recipe_screen.dart  # Edit existing recipe
│   │   ├── review_ingredients_screen.dart  # Review parsed ingredients
│   │   ├── shopping_lists_screen.dart   # Shopping lists grid
│   │   ├── shopping_list_detail_screen.dart  # List with checkboxes
│   │   ├── create_shopping_list_screen.dart  # Create new list
│   │   └── settings_screen.dart     # App settings
│   ├── services/
│   │   ├── ingredient_parser_service.dart   # Text parsing logic
│   │   ├── ingredient_aggregator_service.dart  # Combine ingredients
│   │   ├── share_service.dart       # Export & share functionality
│   │   └── navigation_service.dart  # Navigation helpers
│   ├── widgets/
│   │   ├── recipe_card.dart         # Recipe list card
│   │   ├── ingredient_card.dart     # Editable ingredient card
│   │   ├── shopping_list_card.dart  # Shopping list grid card
│   │   ├── list_item_tile.dart      # Checkbox list item
│   │   ├── quick_action_card.dart   # Home screen action cards
│   │   └── empty_state_widget.dart  # Empty list placeholder
│   └── utils/
│       ├── app_theme.dart           # Material 3 theme config
│       ├── unit_converter.dart      # Unit normalization
│       └── constants.dart           # App constants
├── test/
│   ├── widget_test.dart             # Widget tests
│   ├── services/                    # Service tests
│   └── utils/                       # Utility tests
├── android/                         # Android platform files
├── ios/                             # iOS platform files
├── pubspec.yaml                     # Dependencies & metadata
└── README.md                        # This file
```

## Tech Stack

- **Flutter** 3.38+ with Material Design 3
- **Provider** for state management
- **share_plus** for sharing functionality
- **intl** for date formatting
- **uuid** for unique identifiers

## Troubleshooting

### Flutter not found
Add Flutter to your PATH:
```bash
# Windows (PowerShell)
$env:Path += ";C:\path\to\flutter\bin"

# macOS/Linux
export PATH="$PATH:/path/to/flutter/bin"
```

### Android SDK not found
1. Open Android Studio > Settings > SDK Manager
2. Install Android SDK and accept licenses:
   ```bash
   flutter doctor --android-licenses
   ```

### iOS build issues (macOS)
```bash
cd ios
pod install
cd ..
flutter clean
flutter run
```

### Check overall setup
```bash
flutter doctor -v
```

## Future Enhancements

- SQLite persistence for data storage
- Recipe search and filtering
- Grocery store API integrations
- Video recipe parsing

## License

MIT License - see LICENSE file for details.
