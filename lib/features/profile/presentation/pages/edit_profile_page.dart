import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/profile_bloc.dart';
import '../widgets/edit_profile_form_widget.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocProvider(
        create: (context) => context.read<ProfileBloc>(),
        child: const _EditProfilePageContent(),
      ),
    );
  }
}

class _EditProfilePageContent extends StatelessWidget {
  const _EditProfilePageContent();

  @override
  Widget build(BuildContext context) {
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
          return const Center(child: Text('Профиль обновлен!'));
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
                  child: const Text('Назад'),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('Неизвестное состояние'));
      },
    );
  }
}
