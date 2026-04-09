import 'dart:io';
import 'package:http/http.dart' as http;

const version = '0.0.1';

void main(List<String> arguments) {
  if (arguments.isEmpty || arguments.first == 'help') {
    printUsage();
  } else if (arguments.first == 'version') {
    print('Dartpedia CLI version $version');
  } else if (arguments.first == 'wikipedia') {  // команда 'wikipedia'
    final inputArgs = arguments.length > 1 ? arguments.sublist(1) : null;
    searchWikipedia(inputArgs);
  } else {
    printUsage();
  }
}

void printUsage() {
  print("Commands: 'help', 'version', 'wikipedia <ARTICLE-TITLE>'");
}

Future<String> getWikipediaArticle(String articleTitle) async {
  final url = Uri.https(
    'en.wikipedia.org',
    '/api/rest_v1/page/summary/$articleTitle',
  );
  final response = await http.get(url);
  
  if (response.statusCode == 200) {
    return response.body;
  }
  return 'Error: Failed to fetch article "$articleTitle". Status: ${response.statusCode}';
}

void searchWikipedia(List<String>? arguments) async {
  final String articleTitle;
  
  if (arguments == null || arguments.isEmpty) {
    print('Please provide an article title.');
    final input = stdin.readLineSync();
    if (input == null || input.isEmpty) {
      print('No title provided. Exiting.');
      return;
    }
    articleTitle = input;
  } else {
    articleTitle = arguments.join(' ');
  }
  
  print('Looking up "$articleTitle"...');
  final result = await getWikipediaArticle(articleTitle);
  print(result);
}