import 'dart:math';

class RandHelper {
  // Generates a random integer between 0 and size - 1
  static int randomVal(int size) {
    return (size * (Random().nextDouble())).toInt();
  }

  // Generates a random integer between min and max
  static int randomChar(int min, int max) {
    return randomVal(max - min + 1) + min;
  }
}
