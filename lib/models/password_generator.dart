import 'package:cipherbull/utils/rand_helper.dart';

abstract class PasswordGenerator {
  static List<PasswordGenerator> generators = [];

  static void clear() {
    generators.clear();
  }

  static bool isEmpty() {
    return generators.isEmpty;
  }

  static void add(PasswordGenerator pwdg) {
    generators.add(pwdg);
  }

  String getChar();

  static PasswordGenerator getRandomPassGen() {
    if (generators.isEmpty) {
      add(LowerCaseGenerator());
    }

    if (generators.length == 1) return generators[0];

    int randomIndex = RandHelper.randomVal(generators.length);
    return generators[randomIndex];
  }

  static String generatePassword(int sizeOfPassword) {
    StringBuffer password = StringBuffer();

    while (sizeOfPassword != 0) {
      password.write(getRandomPassGen().getChar());
      sizeOfPassword--;
    }

    return password.toString();
  }
}

class LowerCaseGenerator extends PasswordGenerator {
  static const int charA = 97; // ASCII value of 'a'
  static const int charZ = 122; // ASCII value of 'z'

  @override
  String getChar() {
    return String.fromCharCode(RandHelper.randomChar(charA, charZ));
  }
}

class UpperCaseGenerator extends PasswordGenerator {
  static const int charA = 65; // ASCII value of 'A'
  static const int charZ = 90; // ASCII value of 'Z'

  @override
  String getChar() {
    return String.fromCharCode(RandHelper.randomChar(charA, charZ));
  }
}

class NumericGenerator extends PasswordGenerator {
  static const int char0 = 48; // ASCII value of '0'
  static const int char9 = 57; // ASCII value of '9'

  @override
  String getChar() {
    return String.fromCharCode(RandHelper.randomChar(char0, char9));
  }
}

class SpecialCharGenerator extends PasswordGenerator {
  static const List<String> specialChars = [
    '!',
    '@',
    '#',
    '\$',
    '%',
    '^',
    '&',
    '*'
  ];

  @override
  String getChar() {
    return specialChars[RandHelper.randomChar(0, specialChars.length - 1)];
  }
}
