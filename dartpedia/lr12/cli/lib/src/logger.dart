import 'dart:io';
import 'package:logging/logging.dart';

/// Инициализирует файловый логгер с указанным именем
Logger initFileLogger(String name) {
  // Включаем иерархическое логирование
  hierarchicalLoggingEnabled = true;

  // Создаем экземпляр логгера
  final logger = Logger(name);
  final now = DateTime.now();

  // Получаем путь к корневой директории проекта
  final scriptFile = File(Platform.script.toFilePath());
  final projectDir = scriptFile.parent.parent.path;

  // Создаем директорию logs, если её нет
  final dir = Directory('$projectDir/logs');
  if (!dir.existsSync()) dir.createSync();

  // Создаем файл лога с уникальным именем (дата + имя логгера)
  final logFile = File(
    '${dir.path}/${now.year}_${now.month}_${now.day}_$name.txt',
  );

  // Устанавливаем уровень логирования (ALL - логируем всё)
  logger.level = Level.ALL;

  // Подписываемся на записи лога и пишем их в файл
  logger.onRecord.listen((record) {
    final msg =
        '[${record.time} - ${record.loggerName}] ${record.level.name}: ${record.message}';
    logFile.writeAsStringSync('$msg \n', mode: FileMode.append);
  });

  return logger;
}