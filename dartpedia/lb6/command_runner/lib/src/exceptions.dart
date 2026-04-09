/// Пользовательское исключение для ошибок парсинга аргументов командной строки.
class ArgumentException extends FormatException {
  /// Команда, которая обрабатывалась в момент ошибки.
  final String? command;

  /// Имя аргумента, который вызвал ошибку.
  final String? argumentName;

  ArgumentException(
    super.message, [
    this.command,
    this.argumentName,
    super.source,
    super.offset,
  ]);

  @override
  String toString() {
    return 'ArgumentException: $message';
  }
}