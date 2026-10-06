import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Profile {
  final String id;
  String name;
  String url;
  String userAgent;

  Profile({
    required this.id,
    required this.name,
    required this.url,
    this.userAgent = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'userAgent': userAgent,
      };

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        id: j['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: j['name'] ?? 'Profile',
        url: j['url'] ?? '',
        userAgent: j['userAgent'] ?? '',
      );
}

class ProfileStore {
  static const _key = 'profiles';

  static Future<List<Profile>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List)
            .map((e) => Profile.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      } catch (_) {}
    }
    return [
      Profile(id: '1', name: 'Personal', url: 'https://www.google.com/'),
      Profile(id: '2', name: 'Work', url: 'https://mail.google.com/'),
      Profile(id: '3', name: 'Social', url: 'https://x.com/'),
      Profile(id: '4', name: 'Research', url: 'https://duckduckgo.com/'),
    ];
  }

  static Future<void> save(List<Profile> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }
}
