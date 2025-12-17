import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import '../models/pes_models.dart';

class PesService {
  final String listingUrl = 'https://pesdb.net/efootball/';
  final String detailBaseUrl = 'https://pesdb.net/efootball/';

  static final http.Client _client = http.Client();
  static String? _cookies;

  // Headers to mimic a real browser and avoid 429 errors
  static final Map<String, String> _baseHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1',
    'Cache-Control': 'max-age=0',
    'Referer': 'https://pesdb.net/',
    'Sec-Fetch-Dest': 'document',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'none',
    'Sec-Fetch-User': '?1',
  };

  static Map<String, String> get headers {
    final h = Map<String, String>.from(_baseHeaders);
    if (_cookies != null) {
      h['Cookie'] = _cookies!;
    }
    return h;
  }

  void _updateCookies(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      if (_cookies != null && _cookies != rawCookie) {
        // Simple merge: semi-colon separated.
        // Note: Real cookie management is complex, but this often suffices for scraping.
        _cookies = rawCookie;
      } else {
        _cookies = rawCookie;
      }
    }
  }

  Future<List<PesCategory>> fetchCategories() async {
    try {
      final uri = kIsWeb
          ? Uri.parse(
              'https://corsproxy.io/?${Uri.encodeComponent(detailBaseUrl)}',
            )
          : Uri.parse(detailBaseUrl);

      final response = await _client.get(uri, headers: headers);
      _updateCookies(response);

      if (response.statusCode == 200) {
        var document = parser.parse(response.body);
        List<PesCategory> categories = [];

        var shortcuts = document.querySelector('div.shortcuts');
        if (shortcuts != null) {
          var links = shortcuts.querySelectorAll('a');
          for (var link in links) {
            String name = link.text.trim();
            String href = link.attributes['href'] ?? '';
            if (name.isNotEmpty && href.isNotEmpty) {
              String fullUrl =
                  href.startsWith('http') ? href : '$detailBaseUrl$href';
              categories.add(PesCategory(name: name, url: fullUrl));
            }
          }
        }
        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<List<PesPlayer>> fetchPlayers(
      {String? customUrl, int page = 1, Map<String, String>? filters}) async {
    try {
      String baseUrlToUse = customUrl ?? listingUrl;

      // Robust URL construction
      Uri parsedBase = Uri.parse(baseUrlToUse);
      Map<String, String> currentQuery = Map.from(parsedBase.queryParameters);

      // Get the base excluding query
      String cleanBaseUrl = parsedBase.replace(query: null).toString();
      // Remove trailing ? if exist
      if (cleanBaseUrl.endsWith('?'))
        cleanBaseUrl = cleanBaseUrl.substring(0, cleanBaseUrl.length - 1);

      // 1. Merge filters
      if (filters != null) {
        currentQuery.addAll(filters);
      }

      // 2. Add page param
      if (page > 1) {
        currentQuery['page'] = page.toString();
      }

      // 3. Reconstruct
      currentQuery.removeWhere((k, v) => v.isEmpty);

      String finalUrl = cleanBaseUrl;
      if (currentQuery.isNotEmpty) {
        finalUrl = Uri.parse(cleanBaseUrl)
            .replace(queryParameters: currentQuery)
            .toString();
      }

      String url = finalUrl;

      print('Fetching URL: $url');

      final uri = kIsWeb
          ? Uri.parse('https://corsproxy.io/?${Uri.encodeComponent(url)}')
          : Uri.parse(url);

      final response = await _client.get(uri, headers: headers);
      _updateCookies(response);

      if (response.statusCode == 200) {
        var document = parser.parse(response.body);
        List<PesPlayer> players = [];

        var rows = document.querySelectorAll('tr');

        for (var row in rows) {
          String? name;
          String? id;
          String? club;
          String? nationality;

          var links = row.querySelectorAll('a');

          for (var link in links) {
            String href = link.attributes['href'] ?? '';
            String text = link.text.trim();

            if (href.contains('id=')) {
              if (text.isNotEmpty) {
                name = text;
                Uri uri;
                try {
                  if (href.startsWith('http')) {
                    uri = Uri.parse(href);
                  } else {
                    uri = Uri.parse(
                      'http://fake.com/${href.startsWith('/') ? href.substring(1) : href}',
                    );
                  }

                  if (uri.queryParameters.containsKey('id')) {
                    id = uri.queryParameters['id'];
                  }
                } catch (e) {
                  print('Error parsing ID uri: $href');
                }
              }
            } else if (href.contains('club_team=')) {
              club = text;
            } else if (href.contains('nationality=')) {
              nationality = text;
            }
          }

          if (id != null && name != null) {
            players.add(
              PesPlayer(
                id: id,
                name: name,
                club: club ?? 'Free Agent',
                nationality: nationality ?? 'Unknown',
              ),
            );
          }
        }
        return players;
      } else {
        throw Exception('Failed to load page: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching players: $e');
      rethrow;
    }
  }

  Future<PesPlayerDetail> fetchPlayerDetail(
    PesPlayer player, {
    String mode = 'level1',
  }) async {
    try {
      String url = '$detailBaseUrl?id=${player.id}';
      if (mode == 'max_level') {
        url += '&mode=max_level';
      }

      final uri = kIsWeb
          ? Uri.parse('https://corsproxy.io/?${Uri.encodeComponent(url)}')
          : Uri.parse(url);
      print(uri);
      final response = await _client.get(uri, headers: headers);
      _updateCookies(response);

      if (response.statusCode == 200) {
        var document = parser.parse(response.body);

        String position = 'Unknown';
        String height = 'Unknown';
        String age = 'Unknown';
        String foot = 'Unknown';
        String playingStyle = 'Unknown';
        List<String> skills = [];
        Map<String, String> stats = {};
        Map<String, String> info = {};
        Map<String, int> suggestedPoints = {};

        var rows = document.querySelectorAll('tr');
        for (var row in rows) {
          var th = row.querySelector('th');
          var td = row.querySelector('td');

          if (th != null && td != null) {
            String headerOriginal = th.text.trim().replaceAll(':', '').trim();
            String header = headerOriginal.toLowerCase();
            String value = td.text.trim();

            if (header == 'position') {
              position = value;
            } else if (header == 'height') {
              height = value;
            } else if (header == 'age') {
              age = value;
            } else if (header == 'foot') {
              foot = value;
            } else if (header == 'playing_styles') {
              playingStyle = value;
            } else if (header == 'player skills') {
              String skillsText = td.text.trim();
              if (skillsText.isNotEmpty) {
                var skillsList = skillsText
                    .split('\n')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();
                skills.addAll(skillsList);
              }

              if (skills.isEmpty) {
                for (var node in td.nodes) {
                  if (node.nodeType == Node.TEXT_NODE) {
                    var val = node.text?.trim();
                    if (val != null && val.isNotEmpty) {
                      skills.add(val);
                    }
                  }
                }
              }
            } else if (header == 'ai playing styles') {
              String aiStylesText = td.text.trim();
              List<String> styles = [];

              if (aiStylesText.isNotEmpty) {
                styles = aiStylesText
                    .split('\n')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();
              }

              if (styles.isEmpty) {
                for (var node in td.nodes) {
                  if (node.nodeType == Node.TEXT_NODE) {
                    var val = node.text?.trim();
                    if (val != null && val.isNotEmpty) {
                      styles.add(val);
                    }
                  }
                }
              }

              if (styles.isNotEmpty) {
                info[headerOriginal] = styles.join('\n');
              }
            } else {
              // More permissive check: match number or number with parens text
              // Clean spaces first
              String valClean = value.replaceAll(RegExp(r'\s+'), '');
              if (RegExp(r'^(\(\+\d+\))?\d+$').hasMatch(valClean)) {
                stats[headerOriginal] = value;
              } else {
                info[headerOriginal] = value;
              }
            }
          }
        }

        // Robust parsing for Suggested Points
        try {
          // Find the specific header div "Suggested points for Level X"
          // usage of 'contains' instead of 'startsWith' to be safer
          // check that it has NO div children to ensure we have the inner header
          var allDivs = document.querySelectorAll('div');
          var suggestedHeader = allDivs.firstWhere(
            (d) =>
                d.text.trim().contains('Suggested points for Level') &&
                d.children.where((c) => c.localName == 'div').isEmpty,
            orElse: () => Element.tag('div'),
          );

          if (suggestedHeader.text.isNotEmpty &&
              suggestedHeader.parent != null) {
            var container = suggestedHeader.parent!;

            for (var child in container.children) {
              if (child == suggestedHeader) continue;

              if (child.localName == 'div' && child.text.contains(':')) {
                var span = child.querySelector('span');
                if (span != null) {
                  String fullText = child.text.trim();
                  int colonIndex = fullText.indexOf(':');
                  if (colonIndex > 0) {
                    String keyRaw = fullText.substring(0, colonIndex);
                    String key = keyRaw
                        .replaceAll(RegExp(r'[•\u2022]'), '')
                        .replaceAll('&bull;', '')
                        .trim();

                    String valStr = span.text.trim();
                    int? val = int.tryParse(valStr);
                    if (val != null) {
                      suggestedPoints[key] = val;
                    }
                  }
                }
              }
            }
          }
        } catch (e) {
          print('Error parsing suggested points: $e');
        }

        var playingStylesTable = document.querySelector('table.playing_styles');
        if (playingStylesTable != null) {
          var styleRows = playingStylesTable.querySelectorAll('tr');
          String currentSection = '';

          for (var row in styleRows) {
            var th = row.querySelector('th');
            if (th != null) {
              String header = th.text.trim().toLowerCase();
              if (header == 'playing style') {
                currentSection = 'playing_style';
              } else if (header == 'player skills') {
                currentSection = 'player_skills';
              } else {
                currentSection = '';
              }
            } else {
              var td = row.querySelector('td');
              if (td != null) {
                String value = td.text.trim();
                if (value.isNotEmpty) {
                  if (currentSection == 'playing_style') {
                    playingStyle = value;
                  } else if (currentSection == 'player_skills') {
                    skills.add(value);
                  }
                }
              }
            }
          }
        }

        String description = '';
        var bottomDesc = document.querySelector('.bottom-description h2');
        if (bottomDesc != null) {
          description = bottomDesc.text.trim();
        }

        return PesPlayerDetail(
          player: player,
          position: position,
          height: height,
          age: age,
          foot: foot,
          stats: stats,
          info: info,
          playingStyle: playingStyle,
          skills: skills,
          suggestedPoints: suggestedPoints,
          description: description,
        );
      } else {
        throw Exception(
          'Failed to load player details: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching player details: $e');
      rethrow;
    }
  }
}
