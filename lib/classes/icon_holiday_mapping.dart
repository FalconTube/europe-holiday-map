import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconHolidayMapping {
  final Map<String, IconData> wordMap = {
    "new": FontAwesomeIcons.champagneGlasses,
    "spring": FontAwesomeIcons.clover,
    "easter": FontAwesomeIcons.egg,
    "summer": FontAwesomeIcons.umbrellaBeach,
    "autumn": FontAwesomeIcons.leaf,
    "winter": FontAwesomeIcons.snowflake,
    "christmas": FontAwesomeIcons.gift,
    "labour": FontAwesomeIcons.briefcase,
    "labor": FontAwesomeIcons.briefcase,
    "church": FontAwesomeIcons.church,
    "union": FontAwesomeIcons.handshake,
    "victory": FontAwesomeIcons.handshake,
    "carnival": FontAwesomeIcons.martiniGlassCitrus,
    "lesson": FontAwesomeIcons.graduationCap
  };

  Icon getMatchingIcon(String word) {
    for (final key in wordMap.keys) {
      if (word.toLowerCase().contains(key)) return Icon(wordMap[key]!);
    }
    // If no match found, return default
    return Icon(FontAwesomeIcons.faceGrin);
  }
}
