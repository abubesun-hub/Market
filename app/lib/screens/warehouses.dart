import 'package:flutter/material.dart';
import '../services/api_client.dart';

class WarehousesScreen extends StatefulWidget {
  final bool isArabic;
  const WarehousesScreen({super.key, required this.isArabic});

  @override
  State<WarehousesScreen> createState() => _WarehousesScreenState();
}

class _WarehousesScreenState extends State<WarehousesScreen> {
  final _api = ApiClient();
  int? _selectedBranchId;
  late Future<List<Map<String, dynamic>>> _future;
  List<Map<String, dynamic>> _branches = [];

  @override
  void initState() {
    super.initState();
    _loadBranches();
    _future = _api.listWarehouses();
  }

  Future<void> _loadBranches() async {
    _branches = await _api.listBranches();
    setState(() {});
  }

  void _refresh() {
    setState(() {
      _future = _api.listWarehouses(branchId: _selectedBranchId);
    });
  }

  void _openCreateDialog() async {
    final result = await showDialog<_WhFormResult>(
      context: context,
      builder: (_) => _WhDialog(isArabic: widget.isArabic, branches: _branches),
    );
    if (result != null) {
      await _api.createWarehouse(code: result.code, name: result.name, branchId: result.branchId);
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
          title: Text(isArabic ? 'المخازن' : 'Warehouses'),
          actions: [
            IconButton(onPressed: _openCreateDialog, icon: const Icon(Icons.add), tooltip: isArabic ? 'إضافة' : 'Add'),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedBranchId,
                      decoration: InputDecoration(labelText: isArabic ? 'الفرع' : 'Branch'),
                      items: [
                        DropdownMenuItem(value: null, child: Text(isArabic ? 'الكل' : 'All')),
                        ..._branches.map((b) => DropdownMenuItem(
                              value: b['id'] as int,
                              child: Text('${b['code']} - ${b['name']}'),
                            )),
                      ],
                      onChanged: (v) {
                        _selectedBranchId = v;
                        _refresh();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: _refresh, child: Text(isArabic ? 'تحديث' : 'Refresh')),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
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
                      return Center(child: Text(isArabic ? 'لا توجد مخازن' : 'No warehouses'));
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final w = items[i];
                        return ListTile(
                          leading: const Icon(Icons.warehouse),
                          title: Text('${w['code']} - ${w['name']}'),
                          subtitle: Text('Branch ID: ${w['branch_id']}'),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhDialog extends StatefulWidget {
  final bool isArabic;
  final List<Map<String, dynamic>> branches;
  const _WhDialog({required this.isArabic, required this.branches});

  @override
  State<_WhDialog> createState() => _WhDialogState();
}

class _WhDialogState extends State<_WhDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  int? _branchId;

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.isArabic;
    return AlertDialog(
      title: Text(isArabic ? 'إضافة مخزن' : 'Add Warehouse'),
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
              DropdownButtonFormField<int>(
                initialValue: _branchId,
                decoration: InputDecoration(labelText: isArabic ? 'الفرع' : 'Branch'),
                items: widget.branches
                    .map((b) => DropdownMenuItem(
                          value: b['id'] as int,
                          child: Text('${b['code']} - ${b['name']}'),
                        ))
                    .toList(),
                validator: (v) => v == null ? (isArabic ? 'اختر فرع' : 'Select branch') : null,
                onChanged: (v) => setState(() => _branchId = v),
              )
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(isArabic ? 'إلغاء' : 'Cancel')),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _WhFormResult(_codeCtrl.text, _nameCtrl.text, _branchId!));
            }
          },
          child: Text(isArabic ? 'حفظ' : 'Save'),
        ),
      ],
    );
  }
}

class _WhFormResult {
  final String code;
  final String name;
  final int branchId;
  _WhFormResult(this.code, this.name, this.branchId);
}