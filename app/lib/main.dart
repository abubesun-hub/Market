import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/branches.dart';
import 'screens/warehouses.dart';
import 'services/api_client.dart';

void main() {
  runApp(const MarketApp());
}

class MarketApp extends StatefulWidget {
  const MarketApp({super.key});

  @override
  State<MarketApp> createState() => _MarketAppState();
}

class _MarketAppState extends State<MarketApp> {
  Locale _locale = const Locale('ar'); // default Arabic

  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = _locale.languageCode == 'ar';
    return MaterialApp(
      title: 'Market',
      locale: _locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        fontFamily: isArabic ? 'NotoNaskhArabic' : null,
      ),
      home: HomeScreen(onToggleLocale: _toggleLocale, isArabic: isArabic),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleLocale;
  final bool isArabic;
  const HomeScreen({super.key, required this.onToggleLocale, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'نظام الماركت' : 'Market System'),
          actions: [
            IconButton(
              onPressed: onToggleLocale,
              icon: const Icon(Icons.language),
              tooltip: 'Lang',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _NavCard(
                icon: Icons.settings,
                title: isArabic ? 'الإعدادات' : 'Settings',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsScreen(isArabic: isArabic)));
                },
              ),
              _NavCard(
                icon: Icons.apartment,
                title: isArabic ? 'الفروع' : 'Branches',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => BranchesScreen(isArabic: isArabic)));
                },
              ),
              _NavCard(
                icon: Icons.warehouse,
                title: isArabic ? 'المخازن' : 'Warehouses',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => WarehousesScreen(isArabic: isArabic)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _NavCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon, size: 36), const SizedBox(height: 8), Text(title)],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final bool isArabic;
  const SettingsScreen({super.key, required this.isArabic});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _api = ApiClient();
  final _formKey = GlobalKey<FormState>();
  final _iqdStepCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();

  bool _loading = true;
  Map<String, dynamic>? _settings;
  Map<String, dynamic>? _latestRate;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await _api.getSettings();
      final r = await _api.getLatestExchangeRate();
      setState(() {
        _settings = s;
        _latestRate = r;
        _iqdStepCtrl.text = (s['iqd_step'] ?? 250).toString();
        if (r['rate'] != null) _rateCtrl.text = (r['rate']).toString();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    final iqdStep = int.tryParse(_iqdStepCtrl.text);
    try {
      await _api.updateSettings(iqdStep: iqdStep);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.isArabic ? 'تم الحفظ' : 'Saved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _saveRate() async {
    if (_rateCtrl.text.trim().isEmpty) return;
    final rate = double.tryParse(_rateCtrl.text);
    if (rate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.isArabic ? 'سعر غير صالح' : 'Invalid rate')));
      return;
    }
    final today = DateTime.now();
    final effective = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    try {
      await _api.setExchangeRate(effective: effective, rate: rate);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.isArabic ? 'تم تحديث السعر' : 'Rate updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.isArabic;
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(isArabic ? 'الإعدادات' : 'Settings')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isArabic ? 'تقريب الدينار' : 'IQD Rounding'),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 180,
                            child: TextFormField(
                              controller: _iqdStepCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: isArabic ? 'الخطوة (مثلاً 250)' : 'Step (e.g. 250)',
                              ),
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null || n <= 0) return isArabic ? 'قيمة غير صالحة' : 'Invalid value';
                                return null;
                              },
                            ),
                          ),
                          FilledButton(onPressed: _saveSettings, child: Text(isArabic ? 'حفظ' : 'Save')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(isArabic ? 'سعر الصرف (USD → IQD)' : 'Exchange Rate (USD → IQD)'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _rateCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: isArabic ? 'السعر' : 'Rate',
                                helperText: _latestRate != null && _latestRate!['rate'] != null
                                    ? (isArabic
                                        ? 'آخر سعر: ${_latestRate!['rate']} (${_latestRate!['effective_date']})'
                                        : 'Last rate: ${_latestRate!['rate']} (${_latestRate!['effective_date']})')
                                    : (isArabic ? 'لم يتم إدخال سعر سابق' : 'No previous rate'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(onPressed: _saveRate, child: Text(isArabic ? 'تحديث' : 'Update')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}