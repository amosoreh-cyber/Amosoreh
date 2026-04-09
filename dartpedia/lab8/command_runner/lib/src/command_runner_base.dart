import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'arguments.dart';
import 'exceptions.dart';

class CommandRunner {
  /// Конструктор с опциональными обработчиками вывода и ошибок
  CommandRunner({this.onOutput, this.onError});

  final Map<String, Command> _commands = <String, Command>{};
  
  /// Обработчик вывода (вызывается при выводе результата команды)
  FutureOr<void> Function(String)? onOutput;
  
  /// Обработчик ошибок (вызывается при возникновении исключения)
  FutureOr<void> Function(Object)? onError;

  UnmodifiableSetView<Command> get commands =>
      UnmodifiableSetView<Command>(<Command>{..._commands.values});

  /// Запускает выполнение команды с переданными аргументами
  Future<void> run(List<String> input) async {
    try {
      final ArgResults results = parse(input);
      if (results.command != null) {
        Object? output = await results.command!.run(results);
        if (onOutput != null) {
          await onOutput!(output.toString());
        } else {
          print(output.toString());
        }
      }
    } on Exception catch (exception) {
      if (onError != null) {
        onError!(exception);
      } else {
        rethrow;
      }
    }
  }

  /// Добавляет команду в runner
  void addCommand(Command command) {
    _commands[command.name] = command;
    command.runner = this;
  }

  /// Парсит аргументы командной строки
  ArgResults parse(List<String> input) {
    ArgResults results = ArgResults();
    if (input.isEmpty) return results;

    // Проверка: команда должна существовать
    if (_commands.containsKey(input.first)) {
      results.command = _commands[input.first];
      input = input.sublist(1);
    } else {
      throw ArgumentException(
        'The first word of input must be a command.',
        null,
        input.first,
      );
    }

    // Проверка: только одна команда
    if (results.command != null &&
        input.isNotEmpty &&
        _commands.containsKey(input.first)) {
      throw ArgumentException(
        'Input can only contain one command. Got ${input.first} and ${results.command!.name}',
        null,
        input.first,
      );
    }

    // Обработка опций
    Map<Option, Object?> inputOptions = {};
    int i = 0;
    while (i < input.length) {
      if (input[i].startsWith('-')) {
        var base = _removeDash(input[i]);
        
        // Проверка: опция должна существовать для данной команды
        var option = results.command!.options.firstWhere(
          (option) => option.name == base || option.abbr == base,
          orElse: () {
            throw ArgumentException(
              'Unknown option ${input[i]}',
              results.command!.name,
              input[i],
            );
          },
        );

        if (option.type == OptionType.flag) {
          inputOptions[option] = true;
          i++;
          continue;
        }

        if (option.type == OptionType.option) {
          // Проверка: для опции требуется аргумент
          if (i + 1 >= input.length) {
            throw ArgumentException(
              'Option ${option.name} requires an argument',
              results.command!.name,
              option.name,
            );
          }
          if (input[i + 1].startsWith('-')) {
            throw ArgumentException(
              'Option ${option.name} requires an argument, but got another option ${input[i + 1]}',
              results.command!.name,
              option.name,
            );
          }
          var arg = input[i + 1];
          inputOptions[option] = arg;
          i++;
        }
      } else {
        // Проверка: только один позиционный аргумент
        if (results.commandArg != null && results.commandArg!.isNotEmpty) {
          throw ArgumentException(
            'Commands can only have up to one argument.',
            results.command!.name,
            input[i],
          );
        }
        results.commandArg = input[i];
      }
      i++;
    }
    results.options = inputOptions;

    return results;
  }

  /// Удаляет дефисы из начала строки
  String _removeDash(String input) {
    if (input.startsWith('--')) {
      return input.substring(2);
    }
    if (input.startsWith('-')) {
      return input.substring(1);
    }
    return input;
  }

  /// Возвращает строку использования
  String get usage {
    final exeFile = Platform.script.path.split('/').last;
    return 'Usage: dart bin/$exeFile <command> [commandArg?] [...options?]';
  }
}