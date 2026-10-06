import 'package:flutter/material.dart';
import 'profile_model.dart';
import 'gecko_webview.dart';

class SplitView extends StatelessWidget {
  final List<Profile> profiles;

  const SplitView({super.key, required this.profiles});

  @override
  Widget build(BuildContext context) {
    final n = profiles.length;
    if (n == 1) {
      return _panel(0);
    }
    if (n == 2) {
      return Column(
        children: [
          Expanded(child: _panel(0)),
          Expanded(child: _panel(1)),
        ],
      );
    }
    if (n == 3) {
      return Column(
        children: [
          Expanded(child: _panel(0)),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _panel(1)),
                Expanded(child: _panel(2)),
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _panel(0)),
              Expanded(child: _panel(1)),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _panel(2)),
              Expanded(child: _panel(3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _panel(int index) {
    final p = profiles[index];
    GeckoWebViewController? controller;

    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF10141D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1D2430)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFF141924),
              borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2233),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF253048)),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Color(0xFF9FB6DF),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    p.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => controller?.reload(),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.refresh, size: 15, color: Color(0xFF8B95A7)),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller?.back(),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.chevron_left, size: 18, color: Color(0xFF8B95A7)),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller?.forward(),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.chevron_right, size: 18, color: Color(0xFF8B95A7)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(7)),
              child: GeckoWebView(
                url: p.url,
                userAgent: p.userAgent,
                onReady: (c) => controller = c,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
