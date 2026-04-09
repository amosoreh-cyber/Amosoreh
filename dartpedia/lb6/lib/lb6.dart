import 'package:command_runner/command_runner.dart';

const version = '0.0.1';

void main(List<String> arguments) {
  var commandRunner = CommandRunner(
    onError: (Object error) {
      if (error is Error) {
        throw error;  // Программистская ошибка — пробрасываем
      }
      if (error is Exception) {
        print('Error: $error');  // Пользовательская ошибка — выводим
      }
    },
  )..addCommand(HelpCommand());
  
  commandRunner.run(arguments);
}