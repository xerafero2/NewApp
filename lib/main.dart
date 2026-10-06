import 'package:flutter/material.dart';
import 'profile_model.dart';
import 'browser_page.dart';

void main() => runApp(const MultiBrowserApp());

class MultiBrowserApp extends StatelessWidget {
  const MultiBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MultiBrowser',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0D12),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4F8CFF),
          surface: Color(0xFF10141D),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Profile> _profiles = [];
  int _selectedSplit = 2;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ProfileStore.load();
    if (!mounted) return;
    setState(() => _profiles = p);
  }

  Future<void> _persist() => ProfileStore.save(_profiles);

  void _showEditDialog([int? index]) {
    final nameCtrl = TextEditingController(text: index != null ? _profiles[index].name : '');
    final urlCtrl = TextEditingController(text: index != null ? _profiles[index].url : '');
    final uaCtrl = TextEditingController(text: index != null ? _profiles[index].userAgent : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141924),
        title: Text(index == null ? 'Tambah Profil' : 'Edit Profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(nameCtrl, 'Nama Profil'),
              const SizedBox(height: 12),
              _field(urlCtrl, 'URL Awal'),
              const SizedBox(height: 12),
              _field(uaCtrl, 'User Agent (Opsional)'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F8CFF)),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final url = urlCtrl.text.trim();
              final ua = uaCtrl.text.trim();
              if (name.isEmpty) return;
              setState(() {
                if (index == null) {
                  _profiles.add(Profile(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    url: url,
                    userAgent: ua,
                  ));
                } else {
                  _profiles[index] = Profile(
                    id: _profiles[index].id,
                    name: name,
                    url: url,
                    userAgent: ua,
                  );
                }
              });
              _persist();
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8B95A7)),
        filled: true,
        fillColor: const Color(0xFF0D1119),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1D2430)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1D2430)),
        ),
      ),
    );
  }

  void _deleteProfile(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141924),
        title: const Text('Hapus Profil'),
        content: Text('Hapus "${_profiles[index].name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              setState(() => _profiles.removeAt(index));
              _persist();
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _launchBrowser() {
    if (_profiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan profil dulu')),
      );
      return;
    }
    final n = _selectedSplit.clamp(1, _profiles.length);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrowserPage(profiles: _profiles.take(n).toList()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10141D),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F8CFF), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 10),
            const Text('MultiBrowser', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _profiles.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada profil.\nTambahkan profil baru.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF8B95A7)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _profiles.length,
                    itemBuilder: (_, i) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141924),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF1D2430)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        leading: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A2233),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF253048)),
                          ),
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Color(0xFF9FB6DF),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          _profiles[i].name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          _profiles[i].url.isEmpty ? '(belum ada URL)' : _profiles[i].url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xFF8B95A7), fontSize: 11),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20, color: Color(0xFF8B95A7)),
                              onPressed: () => _showEditDialog(i),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFE5484D)),
                              onPressed: () => _deleteProfile(i),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFF10141D),
              border: Border(top: BorderSide(color: Color(0xFF1D2430))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showEditDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah Profil'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF2A3346)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'SPLIT LAYAR',
                  style: TextStyle(
                    color: Color(0xFF8B95A7),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(4, (i) {
                    final selected = (i + 1) == _selectedSplit;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedSplit = i + 1),
                          child: Container(
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: selected
                                  ? const LinearGradient(
                                      colors: [Color(0xFF4F8CFF), Color(0xFF3B74E6)],
                                    )
                                  : null,
                              color: selected ? null : const Color(0xFF1A2130),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected ? const Color(0xFF3B74E6) : const Color(0xFF2A3346),
                              ),
                            ),
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: selected ? Colors.white : const Color(0xFFE6EAF2),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _launchBrowser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F8CFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Buka Browser',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
