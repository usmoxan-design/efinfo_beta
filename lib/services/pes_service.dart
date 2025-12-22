// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:http/http.dart' as http;
// import 'package:html/parser.dart' as parser;
// import 'package:html/dom.dart';
// import '../models/pes_models.dart';

// class _CachedResponse {
//   final dynamic data; // Can be http.Response or Map/List
//   final DateTime timestamp;
//   _CachedResponse(this.data, this.timestamp);
// }

// class PesService {
//   // SETTINGS
//   // 1. If you have a backend proxy, put it here (e.g., 'https://your-api.vercel.app/api')
//   // 2. If null, it will use the default Scraper mode.
//   static const String? _apiBaseUrl = 'https://efinfohub.vercel.app/api/';

//   final String listingUrl = 'https://pesdb.net/efootball/';
//   final String detailBaseUrl = 'https://pesdb.net/efootball/';

//   final List<String> _proxies = [
//     'https://corsproxy.io/?',
//     'https://api.allorigins.win/raw?url=',
//     'https://cors-anywhere.herokuapp.com/',
//   ];
//   int _proxyIndex = 0;
//   bool _isRequesting = false;

//   static final http.Client _client = http.Client();
//   static String? _cookies;
//   static DateTime? _lastRequestTime;
//   static final Map<String, _CachedResponse> _cache = {};
//   static const Duration _cacheTTL = Duration(minutes: 60);

//   static final Map<String, String> _baseHeaders = {
//     'User-Agent':
//         'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
//     'Accept':
//         'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
//     'Accept-Language': 'en-US,en;q=0.9',
//     'Connection': 'keep-alive',
//     'Referer': 'https://pesdb.net/',
//   };

//   static Map<String, String> get headers {
//     final h = Map<String, String>.from(_baseHeaders);
//     if (_cookies != null) h['Cookie'] = _cookies!;
//     return h;
//   }

//   void _updateCookies(http.Response response) {
//     String? rawCookie = response.headers['set-cookie'];
//     if (rawCookie != null) {
//       final List<String> newCookies = rawCookie.split(',');
//       final Map<String, String> cookieMap = {};
//       if (_cookies != null) {
//         for (var c in _cookies!.split(';')) {
//           final parts = c.split('=');
//           if (parts.length >= 2)
//             cookieMap[parts[0].trim()] = parts.sublist(1).join('=').trim();
//         }
//       }
//       for (var c in newCookies) {
//         final parts = c.split(';')[0].split('=');
//         if (parts.length >= 2)
//           cookieMap[parts[0].trim()] = parts.sublist(1).join('=').trim();
//       }
//       _cookies = cookieMap.entries.map((e) => '${e.key}=${e.value}').join('; ');
//     }
//   }

//   Future<http.Response> _safeRequest(Uri uri,
//       {int retryCount = 0, bool forceRefresh = false}) async {
//     final String cacheKey = uri.toString();
//     if (!forceRefresh && _cache.containsKey(cacheKey)) {
//       final cached = _cache[cacheKey]!;
//       if (DateTime.now().difference(cached.timestamp) < _cacheTTL &&
//           cached.data is http.Response) {
//         return cached.data as http.Response;
//       }
//     }

//     while (_isRequesting)
//       await Future.delayed(const Duration(milliseconds: 300));
//     _isRequesting = true;

//     if (_lastRequestTime != null) {
//       final diff = DateTime.now().difference(_lastRequestTime!);
//       if (diff.inMilliseconds < 1500)
//         await Future.delayed(
//             Duration(milliseconds: 1500 - diff.inMilliseconds));
//     }

//     try {
//       final response = await _client
//           .get(uri, headers: headers)
//           .timeout(const Duration(seconds: 15));
//       _lastRequestTime = DateTime.now();
//       _updateCookies(response);

//       if (response.statusCode == 200) {
//         _cache[cacheKey] = _CachedResponse(response, DateTime.now());
//         return response;
//       }

//       if (response.statusCode == 429 && retryCount < 3) {
//         await Future.delayed(Duration(seconds: 4 + retryCount));
//         _isRequesting = false;
//         return _safeRequest(uri,
//             retryCount: retryCount + 1, forceRefresh: true);
//       }

//       if (kIsWeb && retryCount < _proxies.length - 1) {
//         _proxyIndex++;
//         _isRequesting = false;
//         return _safeRequest(uri,
//             retryCount: retryCount + 1, forceRefresh: true);
//       }

//       if (_cache.containsKey(cacheKey) &&
//           _cache[cacheKey]!.data is http.Response) {
//         return _cache[cacheKey]!.data as http.Response;
//       }
//       return response;
//     } catch (e) {
//       if (_cache.containsKey(cacheKey) &&
//           _cache[cacheKey]!.data is http.Response) {
//         return _cache[cacheKey]!.data as http.Response;
//       }
//       if (retryCount < 2) {
//         await Future.delayed(Duration(seconds: 2 + retryCount));
//         _isRequesting = false;
//         return _safeRequest(uri,
//             retryCount: retryCount + 1, forceRefresh: true);
//       }
//       rethrow;
//     } finally {
//       _isRequesting = false;
//     }
//   }

//   Uri _buildUri(String url) {
//     if (!kIsWeb) return Uri.parse(url);
//     final proxy = _proxies[_proxyIndex % _proxies.length];
//     return Uri.parse('$proxy${Uri.encodeComponent(url)}');
//   }

//   static String formatStatName(String name) {
//     switch (name) {
//       case 'Place Kicking':
//         return 'Set Piece Taking';
//       case 'Jump':
//         return 'Jumping';
//       case 'GK Reflexes':
//         return 'GK Reflex';
//       case 'Offensive Awareness':
//         return 'Attacking Awareness';
//       default:
//         return name;
//     }
//   }

//   // =================== PUBLIC METHODS ===================

//   Future<List<PesCategory>> fetchCategories() async {
//     if (_apiBaseUrl != null) {
//       final baseUrl = _apiBaseUrl!.endsWith('/')
//           ? _apiBaseUrl!.substring(0, _apiBaseUrl!.length - 1)
//           : _apiBaseUrl;
//       final resp = await http.get(Uri.parse('$baseUrl/categories'));
//       if (resp.statusCode == 200) {
//         List data = jsonDecode(resp.body);
//         print(resp.body);
//         return data.map((e) => PesCategory.fromJson(e)).toList();
//       }
//     }

//     // Scraper Fallback
//     final response = await _safeRequest(_buildUri(detailBaseUrl));
//     var document = parser.parse(response.body);
//     List<PesCategory> categories = [];
//     var shortcuts = document.querySelector('div.shortcuts');
//     if (shortcuts != null) {
//       for (var link in shortcuts.querySelectorAll('a')) {
//         String name = link.text.trim();
//         String href = link.attributes['href'] ?? '';
//         if (name.isNotEmpty && href.isNotEmpty) {
//           categories.add(PesCategory(
//               name: name,
//               url: href.startsWith('http') ? href : '$detailBaseUrl$href'));
//         }
//       }
//     }
//     return categories;
//   }

//   Future<List<PesFeaturedOption>> fetchFeaturedOptions() async {
//     if (_apiBaseUrl != null) {
//       final baseUrl = _apiBaseUrl!.endsWith('/')
//           ? _apiBaseUrl!.substring(0, _apiBaseUrl!.length - 1)
//           : _apiBaseUrl;
//       final resp = await http.get(Uri.parse('$baseUrl/featured-options'));
//       if (resp.statusCode == 200) {
//         List data = jsonDecode(resp.body);
//         return data.map((e) => PesFeaturedOption.fromJson(e)).toList();
//       }
//     }

//     final response = await _safeRequest(_buildUri(listingUrl));
//     List<PesFeaturedOption> options = [];
//     if (response.statusCode == 200) {
//       var document = parser.parse(response.body);
//       var select = document.getElementById('featured') ??
//           document.querySelector('select[name="featured"]');
//       if (select != null) {
//         for (var option in select.querySelectorAll('option')) {
//           String name = option.text.trim();
//           String value = option.attributes['value'] ?? '';
//           if (name.isNotEmpty && value.isNotEmpty && value != "0") {
//             options.add(PesFeaturedOption(name: name, id: value));
//           }
//         }
//       }
//     }
//     return options;
//   }

//   Future<List<PesPlayer>> fetchPlayers(
//       {String? customUrl, int page = 1, Map<String, String>? filters}) async {
//     if (_apiBaseUrl != null) {
//       final baseUrl = _apiBaseUrl!.endsWith('/')
//           ? _apiBaseUrl!.substring(0, _apiBaseUrl!.length - 1)
//           : _apiBaseUrl;
//       String url = '$baseUrl/players?page=$page';
//       if (customUrl != null) url += '&url=${Uri.encodeComponent(customUrl)}';
//       filters?.forEach((k, v) => url += '&$k=$v');
//       final resp = await http.get(Uri.parse(url));
//       if (resp.statusCode == 200) {
//         List data = jsonDecode(resp.body);
//         return data.map((e) => PesPlayer.fromJson(e)).toList();
//       }
//     }

//     // Scraper Fallback
//     String base = customUrl ?? listingUrl;
//     Uri uriBase = Uri.parse(base);
//     Map<String, String> query = Map.from(uriBase.queryParameters);
//     if (filters != null) query.addAll(filters);
//     if (page > 1) query['page'] = page.toString();

//     String finalUrl = uriBase.replace(queryParameters: query).toString();
//     final response = await _safeRequest(_buildUri(finalUrl));
//     var document = parser.parse(response.body);
//     List<PesPlayer> players = [];
//     for (var row in document.querySelectorAll('tr')) {
//       String? name, id, club, nationality;
//       for (var link in row.querySelectorAll('a')) {
//         String href = link.attributes['href'] ?? '';
//         String text = link.text.trim();
//         if (href.contains('id=') && text.isNotEmpty) {
//           name = text;
//           id = Uri.tryParse('https://fake.com/$href')?.queryParameters['id'];
//         } else if (href.contains('club_team='))
//           club = text;
//         else if (href.contains('nationality=')) nationality = text;
//       }
//       if (id != null && name != null) {
//         players.add(PesPlayer(
//             id: id,
//             name: name,
//             club: club ?? 'Free Agent',
//             nationality: nationality ?? 'Unknown'));
//       }
//     }
//     return players;
//   }

//   Future<PesPlayerDetail> fetchPlayerDetail(PesPlayer player,
//       {String mode = 'level1', bool forceRefresh = false}) async {
//     if (_apiBaseUrl != null) {
//       final baseUrl = _apiBaseUrl!.endsWith('/')
//           ? _apiBaseUrl!.substring(0, _apiBaseUrl!.length - 1)
//           : _apiBaseUrl;
//       final resp =
//           await http.get(Uri.parse('$baseUrl/player/${player.id}?mode=$mode'));
//       if (resp.statusCode == 200) {
//         return PesPlayerDetail.fromJson(jsonDecode(resp.body), player);
//       }
//     }

//     // Scraper Fallback
//     String url = '$detailBaseUrl?id=${player.id}';
//     if (mode == 'max_level') url += '&mode=max_level';

//     final response =
//         await _safeRequest(_buildUri(url), forceRefresh: forceRefresh);
//     var document = parser.parse(response.body);

//     String position = 'Unknown',
//         height = 'Unknown',
//         age = 'Unknown',
//         foot = 'Unknown',
//         playingStyle = 'Unknown',
//         description = '';
//     List<String> skills = [];
//     Map<String, String> stats = {}, info = {};
//     Map<String, int> suggestedPoints = {};

//     for (var row in document.querySelectorAll('tr')) {
//       var th = row.querySelector('th'), td = row.querySelector('td');
//       if (th == null || td == null) continue;

//       String originalHeader = th.text.trim().replaceAll(':', '').trim();
//       String header = originalHeader.toLowerCase();
//       String value = td.text.trim();
//       String formattedKey = formatStatName(originalHeader);

//       if (header == 'position')
//         position = value;
//       else if (header == 'height')
//         height = value;
//       else if (header == 'age')
//         age = value;
//       else if (header == 'foot')
//         foot = value;
//       else if (header == 'playing styles')
//         playingStyle = value;
//       else if (header == 'player skills') {
//         skills = value
//             .split('\n')
//             .map((s) => s.trim())
//             .where((s) => s.isNotEmpty)
//             .toList();
//       } else if (header == 'ai playing styles') {
//         info[originalHeader] = value
//             .split('\n')
//             .map((s) => s.trim())
//             .where((s) => s.isNotEmpty)
//             .join('\n');
//       } else {
//         if (RegExp(r'\d').hasMatch(value))
//           stats[formattedKey] = value;
//         else
//           info[formattedKey] = value;
//       }
//     }

//     try {
//       var allDivs = document.querySelectorAll('div');
//       var head = allDivs.firstWhere(
//           (d) => d.text.trim().contains('Suggested points for Level'),
//           orElse: () => Element.tag('div'));
//       if (head.text.isNotEmpty && head.parent != null) {
//         for (var child in head.parent!.children) {
//           if (child.localName == 'div' && child.text.contains(':')) {
//             var span = child.querySelector('span');
//             if (span != null) {
//               String key = child.text
//                   .split(':')[0]
//                   .replaceAll(RegExp(r'[•\u2022]'), '')
//                   .trim();
//               int? val = int.tryParse(span.text.trim());
//               if (val != null) suggestedPoints[key] = val;
//             }
//           }
//         }
//       }
//     } catch (_) {}

//     var bottom = document.querySelector('.bottom-description h2');
//     if (bottom != null) description = bottom.text.trim();

//     return PesPlayerDetail(
//       player: player,
//       position: position,
//       height: height,
//       age: age,
//       foot: foot,
//       stats: stats,
//       info: info,
//       playingStyle: playingStyle,
//       skills: skills,
//       suggestedPoints: suggestedPoints,
//       description: description,
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
// Agar sizning modellar faylingiz shu manzilda bo'lsa
import '../models/pes_models.dart';

/// Ma'lumotlarni kechiktirib olish (caching) uchun ichki model
class _CachedResponse {
  final dynamic data; // http.Response yoki Map/List bo'lishi mumkin
  final DateTime timestamp;
  _CachedResponse(this.data, this.timestamp);
}

class PesService {
  // ==================== ASOSIY SOZLAMALAR ====================
  // 1. Agar sizda Vercel'da deploy qilingan backend proksi bo'lsa, uni shu yerga kiriting.
  // Eslatma: Deploy qilganingizdan so'ng 'your-api-name'ni o'zingizniki bilan almashtiring.
  static const String _apiBaseUrl = 'https://efinfohub.vercel.app/api/';
  // Agar API ishlatilmasin desangiz, null qoldiring.

  final String listingUrl = 'https://pesdb.net/efootball/';
  final String detailBaseUrl = 'https://pesdb.net/efootball/';

  // CORS masalasini hal qilish uchun ishlatiladigan proksilar ro'yxati (asosan web uchun)
  final List<String> _proxies = [
    'https://corsproxy.io/?',
    'https://api.allorigins.win/raw?url=',
    // 'https://cors-anywhere.herokuapp.com/' - bu kamdan-kam ishlaydi
  ];
  int _proxyIndex = 0;
  bool _isRequesting = false;

  // Xavfsizlik va Kesh
  static final http.Client _client = http.Client();
  static String? _cookies;
  static DateTime? _lastRequestTime;
  static final Map<String, _CachedResponse> _cache = {};
  static const Duration _cacheTTL = Duration(minutes: 60);
  static const Duration _rateLimitDelay =
      Duration(milliseconds: 1500); // 1.5s kechikish

  // HTTP so'rovlar uchun standart headerlar
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

  // ==================== ICHKI YORDAMCHI FUNKSIYALAR ====================

  /// HTTP javobdan cookie'larni yangilaydi
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

  /// Rate limiting, kesh va retry mantiqiga ega xavfsiz HTTP so'rov
  Future<http.Response> _safeRequest(Uri uri,
      {int retryCount = 0, bool forceRefresh = false}) async {
    final String cacheKey = uri.toString();

    // Keshni tekshirish
    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (DateTime.now().difference(cached.timestamp) < _cacheTTL &&
          cached.data is http.Response) {
        return cached.data as http.Response;
      }
    }

    // Rate Limitni boshqarish (1.5s kechikishni ta'minlash)
    while (_isRequesting)
      await Future.delayed(const Duration(milliseconds: 300));
    _isRequesting = true;

    if (_lastRequestTime != null) {
      final diff = DateTime.now().difference(_lastRequestTime!);
      if (diff.inMilliseconds < _rateLimitDelay.inMilliseconds)
        await Future.delayed(_rateLimitDelay - diff);
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

      // 429 - Too Many Requests (Rate limitga tushish)
      if (response.statusCode == 429 && retryCount < 3) {
        await Future.delayed(Duration(seconds: 4 + retryCount));
        _isRequesting = false;
        return _safeRequest(uri,
            retryCount: retryCount + 1, forceRefresh: true);
      }

      // Agar webda bo'lsak va xato bo'lsa, keyingi proksiga o'tish
      if (kIsWeb && retryCount < _proxies.length - 1) {
        _proxyIndex++;
        _isRequesting = false;
        return _safeRequest(uri,
            retryCount: retryCount + 1, forceRefresh: true);
      }

      // Xato bo'lsa, agar keshda mavjud bo'lsa, eski ma'lumotni qaytarish
      if (_cache.containsKey(cacheKey) &&
          _cache[cacheKey]!.data is http.Response) {
        return _cache[cacheKey]!.data as http.Response;
      }
      return response;
    } catch (e) {
      // Xato yuz bersa (Timeout/Network), keshni tekshirish
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

  /// Webda ishlatish uchun proksi URL'ni yaratadi
  Uri _buildUri(String url) {
    if (!kIsWeb) return Uri.parse(url);
    final proxy = _proxies[_proxyIndex % _proxies.length];
    return Uri.parse('$proxy${Uri.encodeComponent(url)}');
  }

  /// Stat nomlarini standartlashtirish
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

  /// Kategoriyalar ro'yxatini olish
  Future<List<PesCategory>> fetchCategories() async {
    final baseUrl = _apiBaseUrl.endsWith('/') == true
        ? _apiBaseUrl.substring(0, _apiBaseUrl.length - 1)
        : _apiBaseUrl;

    // 1. Next.js API'dan foydalanish
    final resp = await http.get(Uri.parse('$baseUrl/categories'));
    if (resp.statusCode == 200) {
      List data = jsonDecode(resp.body);
      return data.map((e) => PesCategory.fromJson(e)).toList();
    }

    // 2. Scraper Fallback (agar API ishlamasa yoki null bo'lsa)
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

  /// Feature qilingan tanlovlar ro'yxatini olish (Vaqtinchalik API'da yo'q, faqat Scraper)
  Future<List<PesFeaturedOption>> fetchFeaturedOptions() async {
    // API Route qo'shilmagan, faqat Scraper ishlaydi
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

  /// O'yinchilar ro'yxatini olish (Filtr va Paginatsiya bilan)
  Future<List<PesPlayer>> fetchPlayers(
      {String? customUrl, int page = 1, Map<String, String>? filters}) async {
    final baseUrl = _apiBaseUrl.endsWith('/') == true
        ? _apiBaseUrl.substring(0, _apiBaseUrl.length - 1)
        : _apiBaseUrl;

    // 1. Next.js API'dan foydalanish
    String url = '$baseUrl/players?page=$page';
    if (customUrl != null) url += '&url=${Uri.encodeComponent(customUrl)}';
    filters?.forEach((k, v) => url += '&$k=$v');

    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode == 200) {
      List data = jsonDecode(resp.body);
      return data.map((e) => PesPlayer.fromJson(e)).toList();
    }

    // 2. Scraper Fallback
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
      String? name, id, club, nationality, pos, ovr, style;
      var tds = row.querySelectorAll('td');
      if (tds.length >= 10) {
        pos = tds[1].text.trim(); // Position is usually 2nd column (index 1)
        style = tds[3].text.trim(); // Playing Style is index 3
        ovr = tds[tds.length - 2]
            .text
            .trim(); // Usually OVR is second to last col before hidden IDs or just try specific index
        // More robust: OVR is usually the column with class 'selected' if sorted, but by default it's near end.
        // Let's try index 9 (10th column) which is standard for default view
        if (RegExp(r'^\d+$').hasMatch(tds[9].text.trim())) {
          ovr = tds[9].text.trim();
        } else {
          // Fallback to last column if index 9 isn't a number
          ovr = tds[tds.length - 1].text.trim();
        }
      }

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
          nationality: nationality ?? 'Unknown',
          ovr: ovr ?? '0',
          position: pos ?? 'Unknown',
          playingStyle: style,
        ));
      }
    }
    return players;
  }

  /// O'yinchi tafsilotlarini olish
  Future<PesPlayerDetail> fetchPlayerDetail(PesPlayer player,
      {String mode = 'level1', bool forceRefresh = false}) async {
    final baseUrl = _apiBaseUrl.endsWith('/') == true
        ? _apiBaseUrl.substring(0, _apiBaseUrl.length - 1)
        : _apiBaseUrl;

    // 1. Next.js API'dan foydalanish
    // /api/player/[id]?mode=level1
    final resp =
        await http.get(Uri.parse('$baseUrl/player/${player.id}?mode=$mode'));
    if (resp.statusCode == 200) {
      var data = jsonDecode(resp.body);
      // Ensure the data has some meaningful content
      if (data != null &&
          (data['stats'] != null ||
              data['playingStyle'] != null ||
              data['playing_style'] != null)) {
        return PesPlayerDetail.fromJson(data, player);
      }
    }
    // Agar API xato bersa, pastdagi Scraper Fallbackga o'tamiz

    // 2. Scraper Fallback
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
      else if (header.contains('player skill')) {
        // Use innerHtml to correctly handle <br> tags which td.text might ignore
        String htmlContent = td.innerHtml
            .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
        // Now parse the text from this modified HTML
        String cleanText = parser.parse(htmlContent).body?.text ?? htmlContent;

        skills = cleanText
            .split('\n')
            .map((s) => s.trim())
            .where((s) =>
                s.isNotEmpty &&
                !s.contains('<')) // Filter out any remaining HTML tags
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

    // Tavsiya etilgan ballarni ajratib olish (Scraping)
    try {
      var allDivs = document.querySelectorAll('div');
      var head = allDivs.firstWhere((d) {
        final t = d.text.trim();
        return t.startsWith('Suggested points for Level') &&
            t.length < 150 &&
            d.children.where((c) => c.localName == 'div').isEmpty;
      }, orElse: () => Element.tag('div'));

      if (head.text.isNotEmpty && head.parent != null) {
        // Iterate over siblings including the header itself
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
