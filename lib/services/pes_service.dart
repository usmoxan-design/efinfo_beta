import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import '../models/pes_models.dart';

class _CachedResponse {
  final http.Response response;
  final DateTime timestamp;
  _CachedResponse(this.response, this.timestamp);
}

class PesService {
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
      if (DateTime.now().difference(cached.timestamp) < _cacheTTL)
        return cached.response;
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

      if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!.response;
      return response;
    } catch (e) {
      if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!.response;
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

  Future<List<PesCategory>> fetchCategories() async {
    final uri = _buildUri(detailBaseUrl);
    final response = await _safeRequest(uri);
    final document = parser.parse(response.body);
    final List<PesCategory> list = [];
    final shortcuts = document.querySelector('div.shortcuts');
    if (shortcuts != null) {
      for (var a in shortcuts.querySelectorAll('a')) {
        final name = a.text.trim();
        final href = a.attributes['href'];
        if (name.isNotEmpty && href != null) {
          list.add(PesCategory(
              name: name,
              url: href.startsWith('http') ? href : '$detailBaseUrl$href'));
        }
      }
    }
    return list;
  }

  Future<List<PesFeaturedOption>> fetchFeaturedOptions() async {
    final uri = _buildUri(listingUrl);
    final response = await _safeRequest(uri);
    final List<PesFeaturedOption> options = [];
    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final select = document.getElementById('featured') ??
          document.querySelector('select[name="featured"]');
      if (select != null) {
        for (var opt in select.querySelectorAll('option')) {
          final name = opt.text.trim();
          final val = opt.attributes['value'] ?? '';
          if (name.isNotEmpty && val != "0")
            options.add(PesFeaturedOption(name: name, id: val));
        }
      }
    }
    return options;
  }

  Future<List<PesPlayer>> fetchPlayers(
      {String? customUrl, int page = 1, Map<String, String>? filters}) async {
    String base = customUrl ?? listingUrl;
    final uriBase = Uri.parse(base);
    final query = Map<String, String>.from(uriBase.queryParameters);
    if (filters != null) query.addAll(filters);
    if (page > 1) query['page'] = '$page';
    final finalUrl = uriBase.replace(queryParameters: query).toString();

    final response = await _safeRequest(_buildUri(finalUrl));
    final document = parser.parse(response.body);
    final List<PesPlayer> players = [];

    for (var row in document.querySelectorAll('tr')) {
      String? id, name, club, nation;
      for (var a in row.querySelectorAll('a')) {
        final href = a.attributes['href'] ?? '';
        final text = a.text.trim();
        if (href.contains('id=') && text.isNotEmpty) {
          id = Uri.tryParse('https://fake.com/$href')?.queryParameters['id'];
          name = text;
        } else if (href.contains('club_team=')) {
          club = text;
        } else if (href.contains('nationality=')) {
          nation = text;
        }
      }
      if (id != null && name != null) {
        players.add(PesPlayer(
            id: id,
            name: name,
            club: club ?? 'Free Agent',
            nationality: nation ?? 'Unknown'));
      }
    }
    return players;
  }

  Future<PesPlayerDetail> fetchPlayerDetail(PesPlayer player,
      {String mode = 'level1', bool forceRefresh = false}) async {
    String url = '$detailBaseUrl?id=${player.id}';
    if (mode == 'max_level') url += '&mode=max_level';

    final response =
        await _safeRequest(_buildUri(url), forceRefresh: forceRefresh);
    final document = parser.parse(response.body);

    final Map<String, String> stats = {};
    final Map<String, String> info = {};
    final List<String> skills = [];
    Map<String, int> suggestedPoints = {};
    String position = 'Unknown',
        height = 'Unknown',
        age = 'Unknown',
        foot = 'Unknown',
        playingStyle = 'Unknown',
        description = '';

    for (var row in document.querySelectorAll('tr')) {
      final th = row.querySelector('th'), td = row.querySelector('td');
      if (th == null || td == null) continue;

      final originalKey = th.text.replaceAll(':', '').trim();
      final lowKey = originalKey.toLowerCase();
      final value = td.text.trim();
      final formattedKey = formatStatName(originalKey);

      if (lowKey == 'position')
        position = value;
      else if (lowKey == 'height')
        height = value;
      else if (lowKey == 'age')
        age = value;
      else if (lowKey == 'foot')
        foot = value;
      else if (lowKey == 'playing styles')
        playingStyle = value;
      else if (lowKey == 'player skills') {
        skills.addAll(
            value.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty));
      } else if (lowKey == 'ai playing styles') {
        info[originalKey] = value
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .join('\n');
      } else {
        if (RegExp(r'\d').hasMatch(value))
          stats[formattedKey] = value;
        else
          info[formattedKey] = value;
      }
    }

    try {
      final allDivs = document.querySelectorAll('div');
      final head = allDivs.firstWhere(
          (d) => d.text.trim().contains('Suggested points for Level'),
          orElse: () => Element.tag('div'));
      if (head.text.isNotEmpty && head.parent != null) {
        for (var child in head.parent!.children) {
          if (child.localName == 'div' && child.text.contains(':')) {
            final span = child.querySelector('span');
            if (span != null) {
              final key = child.text
                  .split(':')[0]
                  .replaceAll(RegExp(r'[•\u2022]'), '')
                  .trim();
              final val = int.tryParse(span.text.trim());
              if (val != null) suggestedPoints[key] = val;
            }
          }
        }
      }
    } catch (_) {}

    final bottom = document.querySelector('.bottom-description h2');
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
