class AppStrings {
  static const Map<String, Map<String, String>> _s = {
    // ── Bottom Nav ──────────────────────────────────────────────────────
    'nav_home': {'en': 'Home', 'hi': 'होम'},
    'nav_shopping': {'en': 'Shopping', 'hi': 'खरीदारी'},
    'nav_recipes': {'en': 'Recipes', 'hi': 'रेसिपी'},
    'nav_pantry': {'en': 'Pantry', 'hi': 'पेंट्री'},

    // ── Greetings ───────────────────────────────────────────────────────
    'good_morning': {'en': 'Good Morning ☀️', 'hi': 'सुप्रभात ☀️'},
    'good_afternoon': {'en': 'Good Afternoon 🌤️', 'hi': 'नमस्ते 🌤️'},
    'good_evening': {'en': 'Good Evening 🌙', 'hi': 'शुभ संध्या 🌙'},
    'whats_on_list': {
      'en': "What's on your list today?",
      'hi': 'आज क्या चाहिए?',
    },

    // ── Home sections ───────────────────────────────────────────────────
    'todays_list': {'en': "Today's List", 'hi': 'आज की सूची'},
    'categories': {'en': 'Categories', 'hi': 'श्रेणियाँ'},
    'recurring': {'en': '🔁 Recurring', 'hi': '🔁 नियमित'},
    'see_all': {'en': 'See All', 'hi': 'सब देखें'},

    // ── Stat cards ──────────────────────────────────────────────────────
    'to_buy': {'en': 'To Buy', 'hi': 'खरीदना है'},
    'recipes': {'en': 'Recipes', 'hi': 'रेसिपी'},
    'in_pantry': {'en': 'In Pantry', 'hi': 'पेंट्री में'},

    // ── Shopping ────────────────────────────────────────────────────────
    'shopping_list': {'en': 'Shopping List', 'hi': 'खरीदारी सूची'},
    'add_item': {'en': 'Add Item', 'hi': 'आइटम जोड़ें'},
    'search_items': {'en': 'Search items...', 'hi': 'आइटम खोजें...'},
    'to_buy_section': {'en': '🛒 To Buy', 'hi': '🛒 खरीदना है'},
    'bought_section': {'en': '✅ Bought', 'hi': '✅ खरीदा'},
    'often_bought': {'en': '⚡ Often Bought', 'hi': '⚡ अक्सर खरीदा'},
    'list_empty': {'en': 'Your list is empty!', 'hi': 'सूची खाली है!'},
    'tap_to_add': {
      'en': 'Tap + to add your first item',
      'hi': '+ दबाएं और जोड़ें',
    },
    'all_done': {'en': 'All done!', 'hi': 'हो गया! 🎉'},
    'great_shopping': {
      'en': 'Great shopping trip! 🛒',
      'hi': 'बढ़िया खरीदारी!',
    },
    'clear_confirm': {'en': 'Clear Bought Items?', 'hi': 'खरीदे हटाएं?'},
    'clear_desc': {
      'en': 'This permanently removes all ticked items.',
      'hi': 'सभी टिक किए आइटम हट जाएंगे।',
    },
    'clear': {'en': 'Clear', 'hi': 'हटाएं'},

    // ── Recipes ─────────────────────────────────────────────────────────
    'add_recipe': {'en': 'Add Recipe', 'hi': 'रेसिपी जोड़ें'},
    'new_recipe': {'en': 'New Recipe', 'hi': 'नई रेसिपी'},
    'no_recipes': {'en': 'No recipes yet!', 'hi': 'कोई रेसिपी नहीं!'},
    'tap_add_recipe': {
      'en': 'Tap + to save your first recipe',
      'hi': '+ दबाएं',
    },

    // ── Pantry ──────────────────────────────────────────────────────────
    'add_to_pantry': {'en': 'Add to Pantry', 'hi': 'पेंट्री में जोड़ें'},
    'pantry_empty': {'en': 'Your pantry is empty!', 'hi': 'पेंट्री खाली है!'},
    'pantry_alert': {'en': 'Pantry Alert', 'hi': 'पेंट्री अलर्ट'},

    // ── Settings ────────────────────────────────────────────────────────
    'settings': {'en': 'Settings', 'hi': 'सेटिंग्स'},
    'dark_mode': {'en': 'Dark Mode', 'hi': 'डार्क मोड'},
    'dark_mode_sub': {'en': 'Switch to dark theme', 'hi': 'डार्क थीम'},
    'language': {'en': 'Language', 'hi': 'भाषा'},
    'version': {'en': 'Version 1.0.0', 'hi': 'संस्करण 1.0.0'},
    'made_with': {'en': 'Made with Flutter 💙', 'hi': 'Flutter से बनाया 💙'},

    // ── Common ──────────────────────────────────────────────────────────
    'save': {'en': 'Save', 'hi': 'सेव करें'},
    'cancel': {'en': 'Cancel', 'hi': 'रद्द करें'},
    'delete': {'en': 'Delete', 'hi': 'हटाएं'},
  };

  /// Returns the string for [key] in [lang].
  /// Falls back to English if Hindi key is missing.
  static String get(String key, String lang) =>
      _s[key]?[lang] ?? _s[key]?['en'] ?? key;
}
