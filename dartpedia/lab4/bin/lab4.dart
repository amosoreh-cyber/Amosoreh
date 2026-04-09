
import 'package:http/http.dart' as http;
import 'package:command_runner/command_runner.dart';

const version = '1.0.0';

void main(List<String> arguments) async {
  final runner = CommandRunner();
  
  // Регистрируем команды
  runner.registerCommand('version', (args) async {
    print('Version: $version');
  });
  
  runner.registerCommand('wikipedia', (args) async {
    final title = args.isNotEmpty ? args.join(' ') : null;
    await searchWikipedia(title);
  });
  
  runner.registerCommand('help', (args) async {
    print('Commands: version, wikipedia <title>, help');
  });
  
  await runner.run(arguments);
}

Future<void> searchWikipedia(String? title) async {
  if (title == null || title.isEmpty) {
    print('Usage: wikipedia "Article title"');
    return;
  }
  
  print('Searching for: $title');
  final url = Uri.https('en.wikipedia.org', '/api/rest_v1/page/summary/$title');
  final response = await http.get(url);
  
  if (response.statusCode == 200) {
    print('Found!');
    // Здесь можно добавить парсинг JSON
    print(response.body.substring(0, response.body.length > 300 ? 300 : response.body.length));
  } else {
    print('Error: ${response.statusCode}');
  }
}