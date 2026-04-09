import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:wikipedia/src/model/article.dart';
import 'package:wikipedia/src/model/search_results.dart';
import 'package:wikipedia/src/model/summary.dart';

const String dartLangSummaryJson = './test/test_data/dart_lang_summary.json';
const String catExtractJson = './test/test_data/cat_extract.json';
const String openSearchResponse = './test/test_data/open_search_response.json';

void main() {
  group('deserialize example JSON responses from wikipedia API', () {
    // Тест для модели Summary
    test('deserialize Dart Programming Language page summary example data from '
        'json file into a Summary object', () async {
      final String pageSummaryInput =
          await File(dartLangSummaryJson).readAsString();
      final Map<String, Object?> pageSummaryMap =
          jsonDecode(pageSummaryInput) as Map<String, Object?>;
      final Summary summary = Summary.fromJson(pageSummaryMap);
      
      // Проверяем, что данные десериализовались правильно
      expect(summary.titles.canonical, 'Dart_(programming_language)');
      expect(summary.pageid, 33033735);
      expect(summary.lang, 'en');
      expect(summary.description, 'Programming language');
      expect(summary.extract.contains('Dart'), true);
    });

    // Тест для модели Article
    test('deserialize Cat article example data from json file into '
        'an Article object', () async {
      final String articleJson = await File(catExtractJson).readAsString();
      final Map<String, Object?> articleMap =
          jsonDecode(articleJson) as Map<String, Object?>;
      final List<Article> articles = Article.listFromJson(articleMap);
      
      // Проверяем, что статья о кошке
      expect(articles.isNotEmpty, true);
      expect(articles.first.title.toLowerCase(), 'cat');
      expect(articles.first.extract.isNotEmpty, true);
    });

    // Тест для модели SearchResults
    test('deserialize Open Search results example data from json file '
        'into an SearchResults object', () async {
      final String resultsString =
          await File(openSearchResponse).readAsString();
      final List<Object?> resultsAsList =
          jsonDecode(resultsString) as List<Object?>;
      final SearchResults results = SearchResults.fromJson(resultsAsList);
      
      // Проверяем, что результаты поиска корректны
      expect(results.results.length, greaterThan(1));
      expect(results.searchTerm, 'dart');
      expect(results.results.first.title, 'Dart');
      expect(results.results.first.url, 'https://en.wikipedia.org/wiki/Dart');
    });

    // Дополнительный тест: проверка первого результата поиска
    test('first search result should be Dart language', () async {
      final String resultsString =
          await File(openSearchResponse).readAsString();
      final List<Object?> resultsAsList =
          jsonDecode(resultsString) as List<Object?>;
      final SearchResults results = SearchResults.fromJson(resultsAsList);
      
      expect(results.results.first.title, 'Dart');
      expect(results.results.first.url, 'https://en.wikipedia.org/wiki/Dart');
    });
  });
}