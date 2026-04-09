/// Исключение для ошибок, связанных с аргументами командной строки
class ArgumentException extends FormatException {
  /// Команда, которая обрабатывалась в момент возникновения ошибки
  final String? command;

  /// Имя аргумента, вызвавшего ошибку
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