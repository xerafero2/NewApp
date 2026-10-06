import 'package:flutter/material.dart';
import 'profile_model.dart';
import 'split_view.dart';

class BrowserPage extends StatelessWidget {
  final List<Profile> profiles;

  const BrowserPage({super.key, required this.profiles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10141D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MultiBrowser',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2233),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF253048)),
            ),
            child: Text(
              '${profiles.length}-UP',
              style: const TextStyle(
                color: Color(0xFF9FB6DF),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SplitView(profiles: profiles),
    );
  }
}
