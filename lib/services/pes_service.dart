import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import '../models/pes_models.dart';

class _CachedResponse {
  final dynamic data; // Can be http.Response or Map/List
  final DateTime timestamp;
  _CachedResponse(this.data, this.timestamp);
}

class PesService {
  // SETTINGS
  // 1. If you have a backend proxy, put it here (e.g., 'https://your-api.vercel.app/api')
  // 2. If null, it will use the default Scraper mode.
  static const String? _apiBaseUrl = null;

  final String listingUrl = 'https://pesdb.net/efootball/';
  final String detailBaseUrl = 'https://pesdb.net/efootball/';

  final List<String> _proxies = [
    'https://corsproxy.io/?',
    'https://api.allorigins.win/raw?url=',
    'https://cors-anywhere.herokuapp.com/',
  ];
  int _proxyIndex = 0;
  bool _isRequesting = false;

  static final http.Client _client = http.Client();
  static String? _cookies;
  static DateTime? _lastRequestTime;
  static final Map<String, _CachedResponse> _cache = {};
  static const Duration _cacheTTL = Duration(minutes: 60);

  static final Map<String, String> _baseHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
    'Connection': 'keep-alive',
    'Referer': 'https://pesdb.net/',
  };

  static Map<String, String> get headers {
    final h = Map<String, String>.from(_baseHeaders);
    if (_cookies != null) h['Cookie'] = _cookies!;
    return h;
  }

  void _updateCookies(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      final List<String> newCookies = rawCookie.split(',');
      final Map<String, String> cookieMap = {};
      if (_cookies != null) {
        for (var c in _cookies!.split(';')) {
          final parts = c.split('=');
          if (parts.length >= 2)
            cookieMap[parts[0].trim()] = parts.sublist(1).join('=').trim();
        }
      }
      for (var c in newCookies) {
        final parts = c.split(';')[0].split('=');
        if (parts.length >= 2)
          cookieMap[parts[0].trim()] = parts.sublist(1).join('=').trim();
      }
      _cookies = cookieMap.entries.map((e) => '${e.key}=${e.value}').join('; ');
    }
  }

  Future<http.Response> _safeRequest(Uri uri,
      {int retryCount = 0, bool forceRefresh = false}) async {
    final String cacheKey = uri.toString();
    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (DateTime.now().difference(cached.timestamp) < _cacheTTL &&
          cached.data is http.Response) {
        return cached.data as http.Response;
      }
    }

    while (_isRequesting)
      await Future.delayed(const Duration(milliseconds: 300));
    _isRequesting = true;

    if (_lastRequestTime != null) {
      final diff = DateTime.now().difference(_lastRequestTime!);
      if (diff.inMilliseconds < 1500)
        await Future.delayed(
            Duration(milliseconds: 1500 - diff.inMilliseconds));
    }

    try {
      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
      _lastRequestTime = DateTime.now();
      _updateCookies(response);

      if (response.statusCode == 200) {
        _cache[cacheKey] = _CachedResponse(response, DateTime.now());
        return response;
      }

      if (response.statusCode == 429 && retryCount < 3) {
        await Future.delayed(Duration(seconds: 4 + retryCount));
        _isRequesting = false;
        return _safeRequest(uri,
            retryCount: retryCount + 1, forceRefresh: true);
      }

      if (kIsWeb && retryCount < _proxies.length - 1) {
        _proxyIndex++;
        _isRequesting = false;
        return _safeRequest(uri,
            retryCount: retryCount + 1, forceRefresh: true);
      }

      if (_cache.containsKey(cacheKey) &&
          _cache[cacheKey]!.data is http.Response) {
        return _cache[cacheKey]!.data as http.Response;
      }
      return response;
    } catch (e) {
      if (_cache.containsKey(cacheKey) &&
          _cache[cacheKey]!.data is http.Response) {
        return _cache[cacheKey]!.data as http.Response;
      }
      if (retryCount < 2) {
        await Future.delayed(Duration(seconds: 2 + retryCount));
        _isRequesting = false;
        return _safeRequest(uri,
            retryCount: retryCount + 1, forceRefresh: true);
      }
      rethrow;
    } finally {
      _isRequesting = false;
    }
  }

  Uri _buildUri(String url) {
    if (!kIsWeb) return Uri.parse(url);
    final proxy = _proxies[_proxyIndex % _proxies.length];
    return Uri.parse('$proxy${Uri.encodeComponent(url)}');
  }

  static String formatStatName(String name) {
    switch (name) {
      case 'Place Kicking':
        return 'Set Piece Taking';
      case 'Jump':
        return 'Jumping';
      case 'GK Reflexes':
        return 'GK Reflex';
      case 'Offensive Awareness':
        return 'Attacking Awareness';
      default:
        return name;
    }
  }

  // =================== PUBLIC METHODS ===================

  Future<List<PesCategory>> fetchCategories() async {
    if (_apiBaseUrl != null) {
      final resp = await http.get(Uri.parse('$_apiBaseUrl/categories'));
      if (resp.statusCode == 200) {
        List data = jsonDecode(resp.body);
        return data.map((e) => PesCategory.fromJson(e)).toList();
      }
    }

    // Scraper Fallback
    final response = await _safeRequest(_buildUri(detailBaseUrl));
    var document = parser.parse(response.body);
    List<PesCategory> categories = [];
    var shortcuts = document.querySelector('div.shortcuts');
    if (shortcuts != null) {
      for (var link in shortcuts.querySelectorAll('a')) {
        String name = link.text.trim();
        String href = link.attributes['href'] ?? '';
        if (name.isNotEmpty && href.isNotEmpty) {
          categories.add(PesCategory(
              name: name,
              url: href.startsWith('http') ? href : '$detailBaseUrl$href'));
        }
      }
    }
    return categories;
  }

  Future<List<PesFeaturedOption>> fetchFeaturedOptions() async {
    if (_apiBaseUrl != null) {
      final resp = await http.get(Uri.parse('$_apiBaseUrl/featured-options'));
      if (resp.statusCode == 200) {
        List data = jsonDecode(resp.body);
        return data.map((e) => PesFeaturedOption.fromJson(e)).toList();
      }
    }

    final response = await _safeRequest(_buildUri(listingUrl));
    List<PesFeaturedOption> options = [];
    if (response.statusCode == 200) {
      var document = parser.parse(response.body);
      var select = document.getElementById('featured') ??
          document.querySelector('select[name="featured"]');
      if (select != null) {
        for (var option in select.querySelectorAll('option')) {
          String name = option.text.trim();
          String value = option.attributes['value'] ?? '';
          if (name.isNotEmpty && value.isNotEmpty && value != "0") {
            options.add(PesFeaturedOption(name: name, id: value));
          }
        }
      }
    }
    return options;
  }

  Future<List<PesPlayer>> fetchPlayers(
      {String? customUrl, int page = 1, Map<String, String>? filters}) async {
    if (_apiBaseUrl != null) {
      String url = '$_apiBaseUrl/players?page=$page';
      if (customUrl != null) url += '&url=${Uri.encodeComponent(customUrl)}';
      filters?.forEach((k, v) => url += '&$k=$v');
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        List data = jsonDecode(resp.body);
        return data.map((e) => PesPlayer.fromJson(e)).toList();
      }
    }

    // Scraper Fallback
    String base = customUrl ?? listingUrl;
    Uri uriBase = Uri.parse(base);
    Map<String, String> query = Map.from(uriBase.queryParameters);
    if (filters != null) query.addAll(filters);
    if (page > 1) query['page'] = page.toString();

    String finalUrl = uriBase.replace(queryParameters: query).toString();
    final response = await _safeRequest(_buildUri(finalUrl));
    var document = parser.parse(response.body);
    List<PesPlayer> players = [];
    for (var row in document.querySelectorAll('tr')) {
      String? name, id, club, nationality;
      for (var link in row.querySelectorAll('a')) {
        String href = link.attributes['href'] ?? '';
        String text = link.text.trim();
        if (href.contains('id=') && text.isNotEmpty) {
          name = text;
          id = Uri.tryParse('https://fake.com/$href')?.queryParameters['id'];
        } else if (href.contains('club_team='))
          club = text;
        else if (href.contains('nationality=')) nationality = text;
      }
      if (id != null && name != null) {
        players.add(PesPlayer(
            id: id,
            name: name,
            club: club ?? 'Free Agent',
            nationality: nationality ?? 'Unknown'));
      }
    }
    return players;
  }

  Future<PesPlayerDetail> fetchPlayerDetail(PesPlayer player,
      {String mode = 'level1', bool forceRefresh = false}) async {
    if (_apiBaseUrl != null) {
      final resp = await http
          .get(Uri.parse('$_apiBaseUrl/player/${player.id}?mode=$mode'));
      if (resp.statusCode == 200) {
        return PesPlayerDetail.fromJson(jsonDecode(resp.body), player);
      }
    }

    // Scraper Fallback
    String url = '$detailBaseUrl?id=${player.id}';
    if (mode == 'max_level') url += '&mode=max_level';

    final response =
        await _safeRequest(_buildUri(url), forceRefresh: forceRefresh);
    var document = parser.parse(response.body);

    String position = 'Unknown',
        height = 'Unknown',
        age = 'Unknown',
        foot = 'Unknown',
        playingStyle = 'Unknown',
        description = '';
    List<String> skills = [];
    Map<String, String> stats = {}, info = {};
    Map<String, int> suggestedPoints = {};

    for (var row in document.querySelectorAll('tr')) {
      var th = row.querySelector('th'), td = row.querySelector('td');
      if (th == null || td == null) continue;

      String originalHeader = th.text.trim().replaceAll(':', '').trim();
      String header = originalHeader.toLowerCase();
      String value = td.text.trim();
      String formattedKey = formatStatName(originalHeader);

      if (header == 'position')
        position = value;
      else if (header == 'height')
        height = value;
      else if (header == 'age')
        age = value;
      else if (header == 'foot')
        foot = value;
      else if (header == 'playing styles')
        playingStyle = value;
      else if (header == 'player skills') {
        skills = value
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } else if (header == 'ai playing styles') {
        info[originalHeader] = value
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .join('\n');
      } else {
        if (RegExp(r'\d').hasMatch(value))
          stats[formattedKey] = value;
        else
          info[formattedKey] = value;
      }
    }

    try {
      var allDivs = document.querySelectorAll('div');
      var head = allDivs.firstWhere(
          (d) => d.text.trim().contains('Suggested points for Level'),
          orElse: () => Element.tag('div'));
      if (head.text.isNotEmpty && head.parent != null) {
        for (var child in head.parent!.children) {
          if (child.localName == 'div' && child.text.contains(':')) {
            var span = child.querySelector('span');
            if (span != null) {
              String key = child.text
                  .split(':')[0]
                  .replaceAll(RegExp(r'[•\u2022]'), '')
                  .trim();
              int? val = int.tryParse(span.text.trim());
              if (val != null) suggestedPoints[key] = val;
            }
          }
        }
      }
    } catch (_) {}

    var bottom = document.querySelector('.bottom-description h2');
    if (bottom != null) description = bottom.text.trim();

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
  }
}
