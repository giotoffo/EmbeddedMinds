import 'dart:math';

// List of motivational quotes
final List<String> motivationalQuotes = [
  "Every step counts, even the smallest one!",
  "Eat healthy, live better.",
  "Your body will thank you tomorrow for what you do today.",
  "Work out not because you hate your body, but because you love it.",
  "Health is true wealth.",
  "Don't look for excuses, look for results.",
  "Good nutrition is the foundation of every change.",
  "Move every day to love yourself more.",
  "A little exercise today is a big step tomorrow.",
  "The best time to start was yesterday. The second best time is now.",
  "It's not about being perfect, but about being better than yesterday.",
  "Today's sweat is tomorrow's success.",
  "Discipline beats motivation.",
  "Every meal is an opportunity to nourish yourself well.",
  "Physical activity is the most powerful medicine.",
  "Make movement a habit, not an obligation.",
  "Don't give up: change takes time.",
  "Eating well is an act of love toward yourself.",
  "Train to be strong, not just to be thin.",
  "Small daily choices make the difference.",
  "Did you have breakfast today? Remember it's the most important meal of your day.",
];

// Class to manage quotes with a rotating mechanism
class RotatingQuotes {
  static final Random _random = Random();
  static int _lastIndex = -1;

  // Give a random motivational quote from the list
  static String getRandomQuote() {
    if (motivationalQuotes.length <= 1) {
      return motivationalQuotes.first;
    }
    
    int newIndex;
    do {
      newIndex = _random.nextInt(motivationalQuotes.length);
    } while (newIndex == _lastIndex); // Ensure the new index is different from the last one
    
    _lastIndex = newIndex;
    return motivationalQuotes[newIndex];
  }
}

