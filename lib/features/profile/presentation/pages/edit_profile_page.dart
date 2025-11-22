import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../app/providers/profile_providers.dart';
import '../blocs/profile_bloc.dart';
import '../widgets/edit_profile_form_widget.dart';

class EditProfilePage extends ConsumerWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text('profile.edit'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
      ),
      body: BlocProvider.value(
        value: context.read<ProfileBloc>()..add(LoadProfile()),
        child: const _EditProfilePageContent(),
      ),
    );
  }
}

class _EditProfilePageContent extends ConsumerWidget {
  const _EditProfilePageContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProfileLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: EditProfileFormWidget(
              initialProfile: state.profile,
              onSave: (updatedProfile) {
                context.read<ProfileBloc>().add(UpdateProfile(updatedProfile));
              },
              onCancel: () => Navigator.pop(context),
            ),
          );
        } else if (state is ProfileUpdated) {
          // Navigate back when profile is updated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pop(context);
          });
          return Center(child: Text('profile.updated'.tr()));
        } else if (state is ProfileError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Ошибка загрузки профиля',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('common.back'.tr()),
                ),
              ],
            ),
          );
        }

        return Center(child: Text('errors.unknown_state'.tr()));
      },
    );
  }
}
