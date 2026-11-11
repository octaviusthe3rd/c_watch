import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils.dart';
import '../../models/enums.dart';
import '../../providers/report_providers.dart';

class ReportFormScreen extends ConsumerStatefulWidget {
  const ReportFormScreen({super.key});

  @override
  ConsumerState<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends ConsumerState<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _picker = ImagePicker();

  ReportCategory? _category;
  String? _location;
  XFile? _photo;
  bool _categoryError = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // close the options sheet
    final file = await _picker.pickImage(
        source: source, imageQuality: 70, maxWidth: 1600);
    if (file != null && mounted) setState(() => _photo = file);
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => _pickImage(ImageSource.camera)),
          ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => _pickImage(ImageSource.gallery)),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      setState(() => _categoryError = true);
      return;
    }
    FocusScope.of(context).unfocus();
    final ok = await ref.read(reportSubmissionProvider.notifier).submit(
          title: _titleCtrl.text,
          description: _descCtrl.text,
          category: _category!,
          location: _location!,
          photo: _photo,
        );
    if (!mounted || !ok) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
        const SnackBar(content: Text('Report submitted successfully ✅')));
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 18),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: AppColors.textDark)),
      );

  @override
  Widget build(BuildContext context) {
    ref.listen(reportSubmissionProvider, (prev, next) {
      if (next.hasError) {
        context.showSnack('Submission failed: ${next.error}');
      }
    });
    final isLoading = ref.watch(reportSubmissionProvider).isLoading;

    return PopScope(
      canPop: !isLoading,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.showSnack('Please wait for the submission to finish.');
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Report an Incident')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), children: [
              _label('Select a category'),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.35,
                children: [
                  for (final c in ReportCategory.values)
                    _CategoryTile(
                      category: c,
                      selected: _category == c,
                      onTap: () => setState(() {
                        _category = c;
                        _categoryError = false;
                      }),
                    ),
                ],
              ),
              if (_categoryError && _category == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Please select a category',
                      style:
                          TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
                ),
              _label('Title'),
              TextFormField(
                controller: _titleCtrl,
                maxLength: 80,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.minLength(v, 5, 'Title'),
                decoration:
                    const InputDecoration(hintText: 'Briefly describe the issue…'),
              ),
              _label('Description'),
              TextFormField(
                controller: _descCtrl,
                maxLength: 600,
                maxLines: 4,
                validator: (v) => Validators.minLength(v, 20, 'Description'),
                decoration: const InputDecoration(
                    hintText:
                        'Provide more details about the issue…\ne.g. what happened, when, impact, etc.'),
              ),
              _label('Location'),
              DropdownButtonFormField<String>(
                value: _location,
                items: [
                  for (final l in AppConstants.campusLocations)
                    DropdownMenuItem(
                        value: l,
                        child: Text(l, style: const TextStyle(fontSize: 14))),
                ],
                onChanged: (v) => setState(() => _location = v),
                validator: (v) => v == null ? 'Please select a location' : null,
                decoration: const InputDecoration(
                    hintText: 'Where is the issue?',
                    prefixIcon: Icon(Icons.place_outlined)),
              ),
              _label('Add a photo (optional)'),
              if (_photo == null)
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _showPhotoOptions,
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined,
                              color: AppColors.primary, size: 28),
                          SizedBox(height: 8),
                          Text('Tap to add photos',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 13)),
                        ]),
                  ),
                )
              else
                Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(File(_photo!.path),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textDark),
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _photo = null),
                    ),
                  ),
                ]),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('Submit Report'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });
  final ReportCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(category.icon,
                size: 24,
                color: selected ? Colors.white : AppColors.primary),
            const SizedBox(height: 6),
            Text(category.label,
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textDark)),
          ]),
        ),
      );
}