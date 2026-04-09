import 'dart:io';

const String ansiEscapeLiteral = '\x1B';

/// Разбивает строку на строки и выводит их с задержкой
Future<void> write(String text, {int duration = 50}) async {
  final List<String> lines = text.split('\n');
  for (final String l in lines) {
    await _delayedPrint('$l \n', duration: duration);
  }
}

/// Выводит текст с задержкой
Future<void> _delayedPrint(String text, {int duration = 0}) async {
  return Future<void>.delayed(
    Duration(milliseconds: duration),
    () => stdout.write(text),
  );
}

/// RGB цвета для консоли (из Dart brand styleguide)
enum ConsoleColor {
  /// Sky blue - #b8eafe
  lightBlue(184, 234, 254),

  /// Warm red - #F25D50
  red(242, 93, 80),

  /// Light yellow - #F9F8C4
  yellow(249, 248, 196),

  /// Light grey - #F8F9FA
  grey(240, 240, 240),

  /// White
  white(255, 255, 255);

  const ConsoleColor(this.r, this.g, this.b);
  final int r;
  final int g;
  final int b;

  /// Изменяет цвет текста для всего последующего вывода
  String get enableForeground => '$ansiEscapeLiteral[38;2;$r;$g;${b}m';

  /// Изменяет цвет фона для всего последующего вывода
  String get enableBackground => '$ansiEscapeLiteral[48;2;$r;$g;${b}m';

  /// Сбрасывает цвет текста и фона на значения по умолчанию
  static String get reset => '$ansiEscapeLiteral[0m';

  /// Применяет цвет текста к строке
  String applyForeground(String text) {
    return '$ansiEscapeLiteral[38;2;$r;$g;${b}m$text$reset';
  }

  /// Применяет цвет фона к строке
  String applyBackground(String text) {
    return '$ansiEscapeLiteral[48;2;$r;$g;${b}m$text$ansiEscapeLiteral[0m';
  }
}

/// Расширение для строк с методами форматирования
extension TextRenderUtils on String {
  /// Красный текст (для ошибок)
  String get errorText => ConsoleColor.red.applyForeground(this);
  
  /// Желтый текст (для инструкций)
  String get instructionText => ConsoleColor.yellow.applyForeground(this);
  
  /// Голубой текст (для заголовков)
  String get titleText => ConsoleColor.lightBlue.applyForeground(this);

  /// Разбивает строку на строки заданной длины
  List<String> splitLinesByLength(int length) {
    final List<String> words = split(' ');
    final List<String> output = <String>[];
    final StringBuffer strBuffer = StringBuffer();
    
    for (int i = 0; i < words.length; i++) {
      final String word = words[i];
      if (strBuffer.length + word.length <= length) {
        strBuffer.write(word.trim());
        if (strBuffer.length + 1 <= length) {
          strBuffer.write(' ');
        }
      }
      // Если следующее слово превышает длину, начинаем новую строку
      if (i + 1 < words.length &&
          words[i + 1].length + strBuffer.length + 1 > length) {
        output.add(strBuffer.toString().trim());
        strBuffer.clear();
      }
    }
    // Добавляем остаток
    output.add(strBuffer.toString().trim());
    return output;
  }
}