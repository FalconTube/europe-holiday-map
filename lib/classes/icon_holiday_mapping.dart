class IconHolidayMapping {
  final Map<String, String> wordMap = {
    "new": "🎆",
    "spring": "🌷",
    "easter": "🐇",
    "summer": "🏖️",
    "autumn": "🍂",
    "winter": "⛄",
    "christmas": "🎅",
    "labour": "💪",
    "labor": "💪",
    "church": "⛪",
    "union": "🤝",
    "victory": "🤝",
    "carnival": "🪅",
    "lesson": "🎓"
  };

  String getMatchingIcon(String word) {
    for (final key in wordMap.keys) {
      if (word.toLowerCase().contains(key)) return wordMap[key]!;
    }
    // If no match found, return default
    return "😎";
  }
}
