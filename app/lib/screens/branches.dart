import 'package:flutter/material.dart';
import '../services/api_client.dart';

class BranchesScreen extends StatefulWidget {
  final bool isArabic;
  const BranchesScreen({super.key, required this.isArabic});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  final _api = ApiClient();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.listBranches();
  }

  void _refresh() {
    setState(() {
      _future = _api.listBranches();
    });
  }

  void _openCreateDialog() async {
    final result = await showDialog<_BranchFormResult>(
      context: context,
      builder: (_) => _BranchDialog(isArabic: widget.isArabic),
    );
    if (result != null) {
      await _api.createBranch(code: result.code, name: result.name, address: result.address);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.isArabic;
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'الفروع' : 'Branches'),
          actions: [
            IconButton(
              onPressed: _openCreateDialog,
              icon: const Icon(Icons.add),
              tooltip: isArabic ? 'إضافة' : 'Add',
            ),
          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Center(child: Text(isArabic ? 'لا توجد فروع' : 'No branches'));
            }
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final b = items[i];
                return ListTile(
                  leading: const Icon(Icons.apartment),
                  title: Text('${b['code']} - ${b['name']}'),
                  subtitle: Text(b['address'] ?? ''),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BranchDialog extends StatefulWidget {
  final bool isArabic;
  const _BranchDialog({required this.isArabic});

  @override
  State<_BranchDialog> createState() => _BranchDialogState();
}

class _BranchDialogState extends State<_BranchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.isArabic;
    return AlertDialog(
      title: Text(isArabic ? 'إضافة فرع' : 'Add Branch'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeCtrl,
                decoration: InputDecoration(labelText: isArabic ? 'الرمز' : 'Code'),
                validator: (v) => (v == null || v.isEmpty) ? (isArabic ? 'مطلوب' : 'Required') : null,
              ),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: isArabic ? 'الاسم' : 'Name'),
                validator: (v) => (v == null || v.isEmpty) ? (isArabic ? 'مطلوب' : 'Required') : null,
              ),
              TextFormField(
                controller: _addrCtrl,
                decoration: InputDecoration(labelText: isArabic ? 'العنوان' : 'Address'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(isArabic ? 'إلغاء' : 'Cancel')),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _BranchFormResult(_codeCtrl.text, _nameCtrl.text, _addrCtrl.text.isEmpty ? null : _addrCtrl.text));
            }
          },
          child: Text(isArabic ? 'حفظ' : 'Save'),
        ),
      ],
    );
  }
}

class _BranchFormResult {
  final String code;
  final String name;
  final String? address;
  _BranchFormResult(this.code, this.name, this.address);
}