<div align="center">

<img src="assets/nyom-logo.png" width="200"/>

**Your personal recipe collection book. Save recipes from anywhere, plan your meals, and shop smarter.**

[![Flutter](https://img.shields.io/badge/Flutter-3.44.0-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12.0-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Gemini AI](https://img.shields.io/badge/Gemini-3.1%20Flash--Lite-8E75B2?style=for-the-badge&logo=google&logoColor=white)](https://deepmind.google/models/gemini/)
[![Download APK](https://img.shields.io/badge/Download-APK-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://github.com/mnbvcxzz4869/nyom_recipe_app/releases)
[![UI Design](https://img.shields.io/badge/Figma-UI%20Design-F24E1E?style=for-the-badge&logo=figma&logoColor=white)](https://www.figma.com/design/4TCzo55Cnxs4TSNoZFt9e4/Nyom---Recipe-App?m=auto&t=tDyLd4czeC1mMbLo-1)
[![Demo Video](https://img.shields.io/badge/Demo-Video-4285F4?style=for-the-badge&logo=googledrive&logoColor=white)](https://drive.google.com/file/d/1QNjebbgIujXngamzon5rC531RqaFZkIo/view?usp=sharing)
[![Presentation](https://img.shields.io/badge/Figma-Presentation-F24E1E?style=for-the-badge&logo=figma&logoColor=white)](https://www.figma.com/deck/IWeXaSxSpzQD4GEq8NsdFC)

</div>

Ever find an amazing recipe on Instagram, TikTok, or YouTube, send it to your DMs, like the post, save it, and then never open it again?

Same. That's why I built **Nyom**.

Nyom is a personal recipe collection app that makes it stupid-easy to save, organize, and actually *use* the recipes you find while scrolling. Paste a link, drop in a caption, or type it in yourself. Nyom handles the rest with AI, turning messy social media content into clean, structured recipes you can actually cook from.

---

## 📸 Screenshots

| Home | Home Scrolled | Recipe Collection |
|------|---------------|-------------------|
| <img src="screenshots/home.png" width="200"/> | <img src="screenshots/home-scrolled.png" width="200"/> | <img src="screenshots/recipes.png" width="200"/> |

| Add Recipes - URL | Add Recipes - Text | Add Recipes - Manual |
|-------------------|--------------------|----------------------|
| <img src="screenshots/addrecipes-fromurl.png" width="200"/> | <img src="screenshots/addrecipes-text.png" width="200"/> | <img src="screenshots/addrecipes-manual.png" width="200"/> |

| Recipe Detail | Meal Planner | Grocery List |
|---------------|--------------|--------------|
| <img src="screenshots/recipe-view.png" width="200"/> | <img src="screenshots/planner.png" width="200"/> | <img src="screenshots/grocerylist.png" width="200"/> |

## ✨ Features

### 🤖 AI Recipe Parsing
Nyom can parse recipes in 3 ways:

- **🔗 From a URL**: Paste a YouTube video link or article URL and Nyom extracts the recipe automatically.
  > ⚠️ Note: Direct links to TikTok and Instagram don't work due to their in-app restrictions and Gemini API limitations. Use the text/caption method for those instead.
- **📝 From Text / Caption**: Copy-paste any Instagram caption, YouTube description, or any recipe text and Nyom's AI will parse it into a clean structured recipe.
- **✏️ Manual Input**: Have your own recipe? Just type it in yourself.

### 📅 Meal Planner
Plan your entire week ahead. Assign recipes to specific days and meal slots, and always know what's on the menu.

### 🛒 Grocery List
Automatically generated from your meal plan. No more trying to remember what you need. Nyom collects all the ingredients, categorizes them, and tracks what you've already picked up.

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter (Dart) |
| **Backend & Database** | Supabase (Auth, PostgreSQL, Edge Functions) |
| **AI Parsing** | Google Gemini API (via Supabase Edge Functions) |

## 📲 Download

Grab the latest APK from the [Releases](https://github.com/mnbvcxzz4869/nyom_recipe_app/releases) page.
