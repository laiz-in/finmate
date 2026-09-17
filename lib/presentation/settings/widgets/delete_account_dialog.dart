import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Shows a confirmation + password prompt before deleting the account.
/// Returns the entered password if confirmed, or null if cancelled.
Future<String?> showDeleteAccountDialog(BuildContext context, AppColors colors) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _DeleteAccountDialogContent(colors: colors),
  );
}

class _DeleteAccountDialogContent extends StatefulWidget {
  final AppColors colors;
  const _DeleteAccountDialogContent({required this.colors});

  @override
  State<_DeleteAccountDialogContent> createState() => _DeleteAccountDialogContentState();
}

class _DeleteAccountDialogContentState extends State<_DeleteAccountDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delete your account?',
                style: AppTextStyles.bodyLarge(colors.textPrimary),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),
              Text(
                'This permanently deletes your account and all your data. This cannot be undone.',
                style: AppTextStyles.caption(colors.textSecondary),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 35),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter your password',
                  style: AppTextStyles.body(colors.textPrimary),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                style: AppTextStyles.body(colors.textPrimary),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(null),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.background,
                          foregroundColor: colors.textPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Cancel', style: AppTextStyles.caption(colors.textPrimary)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop(_passwordController.text);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Delete', style: AppTextStyles.caption(Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}