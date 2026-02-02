import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart' as html_parser;

import '../models/ingredient.dart';
import '../utils/logger.dart';
import 'ingredient_parser_service.dart';

/// Result of parsing a recipe URL
class RecipeUrlParseResult {
  final String? title;
  final List<Ingredient> ingredients;
  final String? error;
  final String? rawText;

  RecipeUrlParseResult({
    this.title,
    this.ingredients = const [],
    this.error,
    this.rawText,
  });

  bool get isSuccess => error == null && ingredients.isNotEmpty;
}

/// Service for parsing recipes from URLs
class RecipeUrlParserService {
  static const _timeout = Duration(seconds: 20);

  /// Browser-like headers to avoid being blocked
  static Map<String, String> get _headers => {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        'Cache-Control': 'max-age=0',
      };

  /// Parse a recipe from a URL
  static Future<RecipeUrlParseResult> parseUrl(String url) async {
    try {
      // Validate URL
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme) {
        return RecipeUrlParseResult(error: 'Invalid URL format');
      }

      if (!uri.scheme.startsWith('http')) {
        return RecipeUrlParseResult(error: 'URL must start with http:// or https://');
      }

      // Fetch the page using HttpClient for better control
      Logger.info('Fetching recipe from: $url', tag: 'RecipeUrlParser');

      String responseBody;
      int statusCode;

      // Use dart:io HttpClient with SSL handling for Windows compatibility
      try {
        final client = HttpClient()
          ..connectionTimeout = _timeout
          ..userAgent = _headers['User-Agent']
          // Accept all certificates (helps with Windows SSL issues)
          ..badCertificateCallback = (cert, host, port) => true;

        final request = await client.getUrl(uri);
        // Add headers
        _headers.forEach((key, value) {
          if (key != 'User-Agent') {
            request.headers.set(key, value);
          }
        });

        final response = await request.close().timeout(_timeout);
        statusCode = response.statusCode;

        // Handle redirects manually if needed
        if (response.isRedirect && response.headers.value('location') != null) {
          final redirectUrl = response.headers.value('location')!;
          Logger.info('Following redirect to: $redirectUrl', tag: 'RecipeUrlParser');
          client.close();
          // Recursively follow redirect
          return parseUrl(redirectUrl);
        }

        // Read and decode response body
        final bytes = await response.fold<List<int>>(
          <int>[],
          (previous, element) => previous..addAll(element),
        );

        // Try to decode as UTF-8, fall back to Latin-1
        try {
          responseBody = utf8.decode(bytes);
        } catch (_) {
          responseBody = latin1.decode(bytes);
        }

        client.close();
      } catch (e) {
        Logger.error('HttpClient failed: $e', tag: 'RecipeUrlParser');

        // Provide more specific error messages
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('socket') || errorStr.contains('connection refused')) {
          return RecipeUrlParseResult(
            error: 'Could not connect to the website. Please check your internet connection.',
          );
        }
        if (errorStr.contains('handshake') || errorStr.contains('certificate')) {
          return RecipeUrlParseResult(
            error: 'SSL/Security error connecting to website. Try a different recipe site.',
          );
        }
        if (errorStr.contains('timeout')) {
          return RecipeUrlParseResult(
            error: 'Connection timed out. Please try again.',
          );
        }
        if (errorStr.contains('host') || errorStr.contains('dns')) {
          return RecipeUrlParseResult(
            error: 'Could not find the website. Please check the URL.',
          );
        }

        return RecipeUrlParseResult(
          error: 'Network error: ${e.runtimeType}. Try copying ingredients manually.',
        );
      }

      if (statusCode != 200) {
        if (statusCode == 403) {
          return RecipeUrlParseResult(
            error: 'This website blocked the request. Try copying the ingredients manually.',
          );
        }
        if (statusCode == 404) {
          return RecipeUrlParseResult(
            error: 'Recipe page not found. Please check the URL.',
          );
        }
        return RecipeUrlParseResult(
          error: 'Failed to fetch page (status $statusCode)',
        );
      }

      // Check if we got actual content
      if (responseBody.isEmpty) {
        return RecipeUrlParseResult(
          error: 'Received empty response from website.',
        );
      }

      // Parse HTML
      final document = html_parser.parse(responseBody);

      // Try to find JSON-LD structured data first (most reliable)
      final jsonLdResult = _parseJsonLd(document);
      if (jsonLdResult.isSuccess) {
        Logger.info('Found recipe via JSON-LD: ${jsonLdResult.title}', tag: 'RecipeUrlParser');
        return jsonLdResult;
      }

      // Try microdata format
      final microdataResult = _parseMicrodata(document);
      if (microdataResult.isSuccess) {
        Logger.info('Found recipe via microdata: ${microdataResult.title}', tag: 'RecipeUrlParser');
        return microdataResult;
      }

      // Fallback: try to find ingredients heuristically
      final heuristicResult = _parseHeuristic(document);
      if (heuristicResult.isSuccess) {
        Logger.info('Found recipe via heuristics: ${heuristicResult.title}', tag: 'RecipeUrlParser');
        return heuristicResult;
      }

      return RecipeUrlParseResult(
        error: 'Could not find recipe data on this page. Try copying the ingredients manually.',
      );
    } on SocketException catch (e) {
      Logger.error('Socket error: $e', tag: 'RecipeUrlParser');
      return RecipeUrlParseResult(
        error: 'Network error. Please check your internet connection.',
      );
    } on HandshakeException catch (e) {
      Logger.error('SSL/TLS error: $e', tag: 'RecipeUrlParser');
      return RecipeUrlParseResult(
        error: 'Secure connection failed. The website may have certificate issues.',
      );
    } catch (e) {
      Logger.error('Error parsing URL: $e', tag: 'RecipeUrlParser');
      if (e.toString().contains('TimeoutException')) {
        return RecipeUrlParseResult(error: 'Request timed out. Please try again.');
      }
      return RecipeUrlParseResult(
        error: 'Failed to fetch recipe. Try copying the ingredients manually.',
      );
    }
  }

  /// Parse JSON-LD structured data (schema.org Recipe format)
  static RecipeUrlParseResult _parseJsonLd(dynamic document) {
    try {
      final scripts = document.querySelectorAll('script[type="application/ld+json"]');

      for (final script in scripts) {
        final content = script.text;
        if (content == null || content.isEmpty) continue;

        try {
          final json = jsonDecode(content);
          final recipe = _findRecipeInJson(json);
          if (recipe != null) {
            return _extractFromJsonRecipe(recipe);
          }
        } catch (_) {
          // Invalid JSON, try next script
          continue;
        }
      }
    } catch (e) {
      Logger.debug('JSON-LD parsing failed: $e', tag: 'RecipeUrlParser');
    }
    return RecipeUrlParseResult();
  }

  /// Recursively find a Recipe object in JSON (handles @graph arrays)
  static Map<String, dynamic>? _findRecipeInJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final type = json['@type'];
      if (type == 'Recipe' || (type is List && type.contains('Recipe'))) {
        return json;
      }
      // Check @graph array
      if (json.containsKey('@graph')) {
        return _findRecipeInJson(json['@graph']);
      }
    } else if (json is List) {
      for (final item in json) {
        final result = _findRecipeInJson(item);
        if (result != null) return result;
      }
    }
    return null;
  }

  /// Extract recipe data from JSON-LD Recipe object
  static RecipeUrlParseResult _extractFromJsonRecipe(Map<String, dynamic> recipe) {
    final title = recipe['name'] as String?;
    final rawIngredients = recipe['recipeIngredient'];

    if (rawIngredients == null || rawIngredients is! List) {
      return RecipeUrlParseResult(title: title, error: 'No ingredients found');
    }

    final ingredientStrings = rawIngredients.cast<String>();
    final rawText = ingredientStrings.join('\n');
    final ingredients = IngredientParserService.parseText(rawText);

    return RecipeUrlParseResult(
      title: title,
      ingredients: ingredients,
      rawText: rawText,
    );
  }

  /// Parse microdata format (itemtype="http://schema.org/Recipe")
  static RecipeUrlParseResult _parseMicrodata(dynamic document) {
    try {
      final recipeElement = document.querySelector('[itemtype*="schema.org/Recipe"]');
      if (recipeElement == null) return RecipeUrlParseResult();

      // Get title
      final nameElement = recipeElement.querySelector('[itemprop="name"]');
      final title = nameElement?.text?.trim();

      // Get ingredients
      final ingredientElements = recipeElement.querySelectorAll('[itemprop="recipeIngredient"], [itemprop="ingredients"]');
      if (ingredientElements.isEmpty) return RecipeUrlParseResult(title: title);

      final ingredientStrings = ingredientElements
          .map((e) => e.text?.trim() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();

      final rawText = ingredientStrings.join('\n');
      final ingredients = IngredientParserService.parseText(rawText);

      return RecipeUrlParseResult(
        title: title,
        ingredients: ingredients,
        rawText: rawText,
      );
    } catch (e) {
      Logger.debug('Microdata parsing failed: $e', tag: 'RecipeUrlParser');
    }
    return RecipeUrlParseResult();
  }

  /// Heuristic parsing - look for common ingredient list patterns
  static RecipeUrlParseResult _parseHeuristic(dynamic document) {
    try {
      // Try to find title
      String? title;
      final h1 = document.querySelector('h1');
      if (h1 != null) {
        title = h1.text?.trim();
      }

      // Look for ingredient sections
      final ingredientStrings = <String>[];

      // Common class names for ingredient lists
      final selectors = [
        '.ingredients li',
        '.ingredient-list li',
        '.recipe-ingredients li',
        '[class*="ingredient"] li',
        '.wprm-recipe-ingredient',
        '.tasty-recipe-ingredients li',
        '.mv-create-ingredients li',
        // AllRecipes specific
        '.mntl-structured-ingredients__list-item',
        '[data-ingredient-name]',
      ];

      for (final selector in selectors) {
        try {
          final elements = document.querySelectorAll(selector);
          if (elements.isNotEmpty) {
            for (final el in elements) {
              final text = el.text?.trim();
              if (text != null && text.isNotEmpty && text.length < 200) {
                ingredientStrings.add(text);
              }
            }
            if (ingredientStrings.isNotEmpty) break;
          }
        } catch (_) {
          continue;
        }
      }

      if (ingredientStrings.isEmpty) {
        return RecipeUrlParseResult(title: title);
      }

      final rawText = ingredientStrings.join('\n');
      final ingredients = IngredientParserService.parseText(rawText);

      return RecipeUrlParseResult(
        title: title,
        ingredients: ingredients,
        rawText: rawText,
      );
    } catch (e) {
      Logger.debug('Heuristic parsing failed: $e', tag: 'RecipeUrlParser');
    }
    return RecipeUrlParseResult();
  }
}
