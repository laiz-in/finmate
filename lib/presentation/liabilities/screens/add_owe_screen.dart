import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/owe.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../bloc/owe_cubit.dart';

class AddOweScreen extends StatefulWidget {
  final Owe? existingOwe;
  const AddOweScreen({super.key, this.existingOwe});
  bool get isEditing => existingOwe != null;

  @override
  State<AddOweScreen> createState() => _AddOweScreenState();
}

class _AddOweScreenState extends State<AddOweScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  final _nameFieldKey = GlobalKey<FormFieldState<String>>();
  final _amountFieldKey = GlobalKey<FormFieldState<String>>();

  late DateTime _dueDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingOwe;
    _nameController = TextEditingController(text: existing?.personName ?? '');
    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: existing?.note ?? '');
    _dueDate = existing?.dueDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    final nameValid = _nameFieldKey.currentState?.validate() ?? false;
    final amountValid = _amountFieldKey.currentState?.validate() ?? false;
    if (!nameValid || !amountValid) return;

    final uid = getIt<AuthRepository>().currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    final existing = widget.existingOwe;
    final owe = Owe(
      id: existing?.id ?? const Uuid().v4(),
      uid: uid,
      personName: _nameController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      dueDate: _dueDate,
      note: _noteController.text.trim(),
      createdAt: existing?.createdAt ?? DateTime.now(),
      isSettled: existing?.isSettled ?? false,
      settledAt: existing?.settledAt,
      settledNote: existing?.settledNote,
      isSynced: false,
    );

    await context.read<OweCubit>().save(owe);

    if (!mounted) return;
    Navigator.of(context).pop(true);
    AppSnackbar.showSuccess(context, widget.isEditing ? 'Updated' : 'Added to Owe');
  }

  Widget _fieldError(AppColors colors, String? errorText) {
    if (errorText == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(errorText, style: AppTextStyles.small(colors.error)),
    );
  }

  Widget _sectionLabel(AppColors colors, String text) {
    return Text(text, style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final symbol = context.watch<ProfileCubit>().state.profile?.currencySymbol ?? '';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: Scaffold(
        backgroundColor: colors.background,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Iconsax.arrow_up_1, color: colors.error, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          widget.isEditing ? 'Edit owe' : 'You owe',
                          style: AppTextStyles.heading3(colors.textPrimary),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.border),
                        ),
                        child: Icon(Icons.close_rounded, color: colors.textPrimary, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                _sectionLabel(colors, 'PERSON'),
                const SizedBox(height: 8),
                FormField<String>(
                  key: _nameFieldKey,
                  initialValue: _nameController.text,
                  validator: (_) => _nameController.text.trim().isEmpty ? 'Enter a name' : null,
                  builder: (field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: field.hasError ? colors.error : colors.border),
                          ),
                          child: TextField(
                            controller: _nameController,
                            style: AppTextStyles.body(colors.textPrimary),
                            onChanged: (v) => field.didChange(v),
                            decoration: InputDecoration(
                              hintText: 'e.g. Justin',
                              hintStyle: AppTextStyles.body(colors.textSecondary),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                          ),
                        ),
                        _fieldError(colors, field.errorText),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),

                _sectionLabel(colors, 'AMOUNT'),
                const SizedBox(height: 8),
                FormField<String>(
                  key: _amountFieldKey,
                  initialValue: _amountController.text,
                  validator: (_) {
                    final v = _amountController.text;
                    if (v.trim().isEmpty) return 'Enter an amount';
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                    if (parsed > 10000000) return 'Amount cannot exceed 10,000,000';
                    return null;
                  },
                  builder: (field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: field.hasError ? colors.error : colors.border),
                          ),
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: AppTextStyles.heading3(colors.textPrimary),
                            onChanged: (v) => field.didChange(v),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              prefixText: '$symbol ',
                              prefixStyle: AppTextStyles.heading3(colors.textPrimary),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        _fieldError(colors, field.errorText),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),

                _sectionLabel(colors, 'GIVE BACK BY'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.calendar_1, size: 16, color: colors.primary),
                        const SizedBox(width: 10),
                        Text(
                          '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                          style: AppTextStyles.body(colors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                _sectionLabel(colors, 'NOTE (OPTIONAL)'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border),
                  ),
                  child: TextField(
                    controller: _noteController,
                    style: AppTextStyles.body(colors.textPrimary),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'e.g. For dinner last week',
                      hintStyle: AppTextStyles.body(colors.textSecondary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(widget.isEditing ? 'Update' : 'Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool?> openAddOweSheet(BuildContext context, {Owe? existingOwe}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.95,
      child: AddOweScreen(existingOwe: existingOwe),
    ),
  );
}