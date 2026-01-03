import 'package:flutter/material.dart';

import '../core/api.dart';
import '../core/storage.dart';
import '../routes.dart';

class ProfilePage extends StatefulWidget {
  final bool embedded; 

  const ProfilePage({super.key, this.embedded = true});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _me;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await Api.getMe();
      final userAny = res['user'] ?? res['data'] ?? res;
      final user = (userAny is Map<String, dynamic>)
          ? userAny
          : (userAny is Map)
              ? Map<String, dynamic>.from(userAny)
              : <String, dynamic>{};

      if (!mounted) return;
      setState(() => _me = user);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _fullNameOf(Map<String, dynamic> me) {
    final v = me['full_name'] ?? me['fullName'] ?? me['name'];
    return (v is String && v.trim().isNotEmpty) ? v.trim() : 'Misafir';
  }

  String _emailOf(Map<String, dynamic> me) {
    final v = me['email'];
    return (v is String && v.trim().isNotEmpty) ? v.trim() : 'E-posta belirtilmemiş';
  }

  String? _phoneOf(Map<String, dynamic> me) {
    final v = me['phone'];
    if (v is String && v.trim().isNotEmpty) return v.trim();
    return null;
  }

  String? _avatarUrlOf(Map<String, dynamic> me) {
    final v = me['avatar_url'] ?? me['avatarUrl'];
    return (v is String && v.trim().isNotEmpty) ? v.trim() : null;
  }

  Future<void> _logout() async {
    await Storage.clearToken();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.gate, (r) => false);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _updateProfile({
    String? fullName,
    String? phone,
  }) async {
    final current = _me ?? <String, dynamic>{};
    final nextFullName = (fullName ?? _fullNameOf(current)).trim();
    final nextPhone = (phone ?? (_phoneOf(current) ?? '')).trim();
    final avatarUrl = _avatarUrlOf(current);

    final res = await Api.updateProfile(
      fullName: nextFullName,
      phone: nextPhone,
      avatarUrl: avatarUrl,
    );

    final userAny = res['user'] ?? res['data'] ?? res;
    final user = (userAny is Map<String, dynamic>)
        ? userAny
        : (userAny is Map)
            ? Map<String, dynamic>.from(userAny)
            : <String, dynamic>{};

    if (!mounted) return;
    setState(() => _me = user);
  }

  Future<void> _showEditFullNameSheet() async {
    final me = _me ?? <String, dynamic>{};
    String value = _fullNameOf(me);
    bool saving = false;
    String? err;

    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (sheetCtx) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(sheetCtx).unfocus(),
          child: StatefulBuilder(
            builder: (ctx, setLocal) {
              final bottom = MediaQuery.of(ctx).viewInsets.bottom;

              void setSaving(bool v) => setLocal(() => saving = v);
              void setErr(String? v) => setLocal(() => err = v);

              Future<void> onSave() async {
                if (saving) return;
                FocusScope.of(ctx).unfocus();
                setErr(null);

                if (value.trim().isEmpty) {
                  setErr('Ad soyad boş olamaz.');
                  return;
                }

                setSaving(true);
                try {
                  await _updateProfile(fullName: value.trim());
                  if (!mounted) return;
                  Navigator.of(ctx).pop();
                  _snack('Ad soyad güncellendi.');
                } catch (e) {
                  setSaving(false);
                  setErr(e.toString());
                }
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 14,
                  bottom: 16 + bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: SizedBox(
                        width: 40,
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.all(Radius.circular(99)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ad Soyad Düzenle',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: value,
                      textInputAction: TextInputAction.done,
                      onChanged: (v) => value = v,
                      onFieldSubmitted: (_) => onSave(),
                      decoration: const InputDecoration(
                        labelText: 'Ad Soyad',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (err != null) ...[
                      const SizedBox(height: 10),
                      Text(err!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: saving ? null : onSave,
                        icon: const Icon(Icons.save),
                        label: Text(saving ? 'Kaydediliyor...' : 'Kaydet'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showEditPhoneSheet() async {
    final me = _me ?? <String, dynamic>{};
    String value = _phoneOf(me) ?? '';
    bool saving = false;
    String? err;

    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (sheetCtx) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(sheetCtx).unfocus(),
          child: StatefulBuilder(
            builder: (ctx, setLocal) {
              final bottom = MediaQuery.of(ctx).viewInsets.bottom;

              void setSaving(bool v) => setLocal(() => saving = v);
              void setErr(String? v) => setLocal(() => err = v);

              Future<void> onSave() async {
                if (saving) return;
                FocusScope.of(ctx).unfocus();
                setErr(null);

                if (value.trim().isEmpty) {
                  setErr('Telefon boş olamaz.');
                  return;
                }

                setSaving(true);
                try {
                  await _updateProfile(phone: value.trim());
                  if (!mounted) return;
                  Navigator.of(ctx).pop();
                  _snack('Telefon güncellendi.');
                } catch (e) {
                  setSaving(false);
                  setErr(e.toString());
                }
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 14,
                  bottom: 16 + bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: SizedBox(
                        width: 40,
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.all(Radius.circular(99)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Telefon Düzenle',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: value,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      onChanged: (v) => value = v,
                      onFieldSubmitted: (_) => onSave(),
                      decoration: const InputDecoration(
                        labelText: 'Telefon',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (err != null) ...[
                      const SizedBox(height: 10),
                      Text(err!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: saving ? null : onSave,
                        icon: const Icon(Icons.save),
                        label: Text(saving ? 'Kaydediliyor...' : 'Kaydet'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showChangePasswordSheet() async {
    String oldPass = '';
    String newPass = '';
    String newPass2 = '';
    bool saving = false;
    bool showOld = false;
    bool showNew = false;
    bool showNew2 = false;
    String? err;

    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (sheetCtx) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(sheetCtx).unfocus(),
          child: StatefulBuilder(
            builder: (ctx, setLocal) {
              final bottom = MediaQuery.of(ctx).viewInsets.bottom;

              void setSaving(bool v) => setLocal(() => saving = v);
              void setErr(String? v) => setLocal(() => err = v);

              Future<void> onSave() async {
                if (saving) return;
                FocusScope.of(ctx).unfocus();
                setErr(null);

                if (oldPass.isEmpty || newPass.isEmpty || newPass2.isEmpty) {
                  setErr('Lütfen tüm alanları doldurun.');
                  return;
                }
                if (newPass != newPass2) {
                  setErr('Yeni şifreler eşleşmiyor.');
                  return;
                }
                if (newPass.length < 6) {
                  setErr('Yeni şifre en az 6 karakter olmalı.');
                  return;
                }

                setSaving(true);
                try {
                  await Api.changePassword(oldPassword: oldPass, newPassword: newPass);
                  if (!mounted) return;
                  Navigator.of(ctx).pop();
                  _snack('Şifre değiştirildi.');
                } catch (e) {
                  setSaving(false);
                  setErr(e.toString());
                }
              }

              InputDecoration deco(String label, bool shown, VoidCallback toggle) {
                return InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: toggle,
                    icon: Icon(shown ? Icons.visibility_off : Icons.visibility),
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 14,
                  bottom: 16 + bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: SizedBox(
                        width: 40,
                        height: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.all(Radius.circular(99)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Şifre Değiştir',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      obscureText: !showOld,
                      onChanged: (v) => oldPass = v,
                      decoration: deco('Mevcut şifre', showOld, () => setLocal(() => showOld = !showOld)),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      obscureText: !showNew,
                      onChanged: (v) => newPass = v,
                      decoration: deco('Yeni şifre', showNew, () => setLocal(() => showNew = !showNew)),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      obscureText: !showNew2,
                      onChanged: (v) => newPass2 = v,
                      decoration: deco('Yeni şifre (tekrar)', showNew2, () => setLocal(() => showNew2 = !showNew2)),
                    ),
                    if (err != null) ...[
                      const SizedBox(height: 10),
                      Text(err!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: saving ? null : onSave,
                        icon: const Icon(Icons.save),
                        label: Text(saving ? 'Kaydediliyor...' : 'Kaydet'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _contentList() {
    if (_loading && _me == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _me == null) {
      return Center(child: Text(_error!));
    }

    final me = _me ?? <String, dynamic>{};
    final fullName = _fullNameOf(me);
    final email = _emailOf(me);
    final phone = _phoneOf(me);

    final initial = fullName.trim().isNotEmpty ? fullName.trim()[0].toUpperCase() : 'P';

    return RefreshIndicator(
      onRefresh: _loadMe,
      child: ListView(
        padding: const EdgeInsets.all(16),
        
        children: [
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.35),
            child: ListTile(
              leading: CircleAvatar(child: Text(initial)),
              title: Text(fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(email),
              trailing: IconButton(
                tooltip: 'Ad soyadı düzenle',
                icon: const Icon(Icons.edit),
                onPressed: _showEditFullNameSheet,
              ),
              onTap: _showEditFullNameSheet,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.35),
            child: ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Telefon'),
              subtitle: Text(phone ?? 'Belirtilmedi'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showEditPhoneSheet,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.35),
            child: ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Şifre değiştir'),
              subtitle: const Text('Şifreni güncelle'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showChangePasswordSheet,
            ),
          ),

          
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const buttonHeight = 48.0;

    return Scaffold(
      
      appBar: AppBar(
        title: const Text('PayPark'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          _contentList(),

          
          Positioned(
            left: 16,
            right: 16,
            bottom: 10,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: buttonHeight,
                child: FilledButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Çıkış yap'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
