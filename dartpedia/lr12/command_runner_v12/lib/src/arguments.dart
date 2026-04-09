import 'dart:async';
import 'dart:collection';

import '../command_runner.dart';

/// Тип опции: flag (флаг) или option (опция с значением)
enum OptionType { flag, option }

/// Абстрактный базовый класс для всех аргументов командной строки
abstract class Argument {
  String get name;
  String? get help;
  Object? get defaultValue;
  String? get valueHelp;
  String get usage;
}

/// Класс для представления опций командной строки (--verbose, --output=file.txt)
class Option extends Argument {
  Option(
    this.name, {
    required this.type,
    this.help,
    this.abbr,
    this.defaultValue,
    this.valueHelp,
  });

  @override
  final String name;
  final OptionType type;
  @override
  final String? help;
  final String? abbr;
  @override
  final Object? defaultValue;
  @override
  final String? valueHelp;

  @override
  String get usage {
    if (abbr != null) {
      return '-$abbr,--$name: $help';
    }
    return '--$name: $help';
  }
}

/// Абстрактный класс для представления команд (help, wikipedia, search)
abstract class Command extends Argument {
  @override
  String get name;
  String get description;
  bool get requiresArgument => false;
  late CommandRunner runner;
  @override
  String? help;
  @override
  String? defaultValue;
  @override
  String? valueHelp;

  final List<Option> _options = [];
  UnmodifiableSetView<Option> get options =>
      UnmodifiableSetView(_options.toSet());

  /// Добавляет флаг (булеву опцию)
  void addFlag(String name, {String? help, String? abbr, String? valueHelp}) {
    _options.add(
      Option(
        name,
        help: help,
        abbr: abbr,
        defaultValue: false,
        valueHelp: valueHelp,
        type: OptionType.flag,
      ),
    );
  }

  /// Добавляет опцию с значением
  void addOption(
    String name, {
    String? help,
    String? abbr,
    String? defaultValue,
    String? valueHelp,
  }) {
    _options.add(
      Option(
        name,
        help: help,
        abbr: abbr,
        defaultValue: defaultValue,
        valueHelp: valueHelp,
        type: OptionType.option,
      ),
    );
  }

  /// Выполняет команду
  FutureOr<Object?> run(ArgResults args);

  @override
  String get usage => '$name:  $description';
}

/// Результат парсинга аргументов командной строки
class ArgResults {
  Command? command;
  String? commandArg;
  Map<Option, Object?> options = {};

  /// Проверяет, установлен ли флаг
  bool flag(String name) {
    for (var option in options.keys.where(
      (option) => option.type == OptionType.flag,
    )) {
      if (option.name == name) {
        return options[option] as bool;
      }
    }
    return false;
  }

  /// Проверяет, есть ли опция
  bool hasOption(String name) {
    return options.keys.any((option) => option.name == name);
  }

  /// Получает опцию по имени
  ({Option option, Object? input}) getOption(String name) {
    var mapEntry = options.entries.firstWhere(
      (entry) => entry.key.name == name || entry.key.abbr == name,
    );
    return (option: mapEntry.key, input: mapEntry.value);
  }
}