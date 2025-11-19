import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/profile_image_service.dart';
import '../../domain/entities/user_profile_entity.dart';

class EditProfileFormWidget extends StatefulWidget {
  final UserProfileEntity initialProfile;
  final Function(UserProfileEntity) onSave;
  final VoidCallback? onCancel;

  const EditProfileFormWidget({
    super.key,
    required this.initialProfile,
    required this.onSave,
    this.onCancel,
  });

  @override
  State<EditProfileFormWidget> createState() => _EditProfileFormWidgetState();
}

class _EditProfileFormWidgetState extends State<EditProfileFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late DateTime? _selectedDate;
  late List<String> _selectedInterests;
  File? _profileImage;
  bool _isLoadingImage = false;
  final ImagePicker _picker = ImagePicker();
  final ProfileImageService _profileImageService = ProfileImageService();

  final List<String> _availableInterests = [
    'profile.hobbies.meditation',
    'profile.hobbies.yoga',
    'profile.hobbies.sports',
    'profile.hobbies.reading',
    'profile.hobbies.music',
    'profile.hobbies.art',
    'profile.hobbies.nature',
    'profile.hobbies.travel',
    'profile.hobbies.cooking',
    'profile.hobbies.technology',
    'profile.hobbies.science',
    'profile.hobbies.psychology',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProfile.name);
    _emailController = TextEditingController(
      text: widget.initialProfile.email ?? '',
    );
    _bioController = TextEditingController(
      text: widget.initialProfile.bio ?? '',
    );
    _selectedDate = widget.initialProfile.dateOfBirth;
    _selectedInterests = List.from(widget.initialProfile.interests);
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    setState(() {
      _isLoadingImage = true;
    });

    try {
      final imageFile = await _profileImageService.getProfileImage();
      if (mounted) {
        setState(() {
          _profileImage = imageFile;
          _isLoadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Photo Section
          Center(
            child: _buildProfilePhotoSection(isDark),
          ),

          const SizedBox(height: 32),

          // Name Field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'profile.name'.tr(),
              hintText: 'profile.name_hint'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person_outline),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : AppColors.surface,
            ),
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'profile.name_required'.tr();
              }
              if (value.trim().length < 2) {
                return 'profile.name_min_length'.tr();
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'profile.email'.tr(),
              hintText: 'profile.email_hint'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : AppColors.surface,
            ),
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'profile.email_invalid'.tr();
                }
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Date of Birth Field
          InkWell(
            onTap: _selectDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'profile.date_of_birth'.tr(),
                hintText: 'profile.select_date'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : AppColors.surface,
              ),
              child: Text(
                _selectedDate != null
                    ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                    : 'profile.select_date'.tr(),
                style: AppTypography.bodyLarge.copyWith(
                  color: isDark
                      ? (_selectedDate != null
                          ? Colors.white
                          : Colors.white70)
                      : (_selectedDate != null
                          ? AppColors.textPrimary
                          : AppColors.textHint),
                ),
              ),
            ),
          ),

          if (_selectedDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'profile.age'.tr(namedArgs: {
                'age': widget.initialProfile
                    .copyWith(dateOfBirth: _selectedDate)
                    .age
                    .toString(),
              }),
              style: AppTypography.caption.copyWith(
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Bio Field
          TextFormField(
            controller: _bioController,
            decoration: InputDecoration(
              labelText: 'profile.about'.tr(),
              hintText: 'profile.about_hint'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.info_outline),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : AppColors.surface,
            ),
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            maxLines: 4,
            maxLength: 200,
          ),

          const SizedBox(height: 24),

          // Interests Section
          Text(
            'profile.interests'.tr(),
            style: AppTypography.h4.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableInterests.map((interestKey) {
              final interest = interestKey.tr();
              final isSelected = _selectedInterests.contains(interestKey);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedInterests.add(interestKey);
                    } else {
                      _selectedInterests.remove(interestKey);
                    }
                  });
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: AppTypography.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.white70 : AppColors.textSecondary),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: isDark
                    ? const Color(0xFF1E293B)
                    : AppColors.surfaceVariant,
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel ?? () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.3)
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    'common.cancel'.tr(),
                    style: AppTypography.button.copyWith(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'common.save'.tr(),
                    style: AppTypography.button,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection(bool isDark) {
    return Column(
      children: [
        GestureDetector(
          onTap: _showImagePicker,
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: _profileImage == null
                      ? LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                  image: _profileImage != null
                      ? DecorationImage(
                          image: FileImage(_profileImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _profileImage == null
                    ? _isLoadingImage
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 60,
                          )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _showImagePicker,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text('profile.change_photo'.tr()),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  void _showImagePicker() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final sheetTheme = Theme.of(context);
        final sheetIsDark = sheetTheme.brightness == Brightness.dark;
        
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'profile.select_photo'.tr(),
                style: AppTypography.h3.copyWith(
                  color: sheetIsDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ImagePickerOption(
                    icon: Icons.camera_alt,
                    label: 'profile.camera'.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _ImagePickerOption(
                    icon: Icons.photo_library,
                    label: 'profile.gallery'.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  if (_profileImage != null)
                    _ImagePickerOption(
                      icon: Icons.delete,
                      label: 'common.delete'.tr(),
                      onTap: () {
                        Navigator.pop(context);
                        _removeImage();
                      },
                      isDestructive: true,
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );

      if (image != null) {
        final imageFile = File(image.path);
        setState(() {
          _profileImage = imageFile;
        });

        final success = await _profileImageService.saveProfileImage(imageFile);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('profile.photo_saved'.tr()),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('profile.photo_save_error'.tr()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'profile.image_selection_error'.tr(
                namedArgs: {'error': e.toString()},
              ),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _profileImage = null;
    });

    final success = await _profileImageService.removeProfileImage();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'profile.photo_deleted'.tr()
                : 'profile.photo_delete_error'.tr(),
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = widget.initialProfile.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        dateOfBirth: _selectedDate,
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        interests: _selectedInterests,
      );

      widget.onSave(updatedProfile);
    }
  }
}

class _ImagePickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ImagePickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
