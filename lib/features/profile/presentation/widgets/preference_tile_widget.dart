import 'package:flutter/material.dart';
import 'package:mind_space/presentation/widgets/core/glass_surface.dart';

class PreferenceTileWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const PreferenceTileWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: enabled ? Colors.white : Colors.white.withOpacity(0.6),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: enabled
                      ? Colors.white.withOpacity(0.85)
                      : Colors.white.withOpacity(0.6),
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              )
            : null,
        trailing: trailing,
        onTap: enabled ? onTap : null,
        enabled: enabled,
      ),
    );
  }
}

class SwitchPreferenceTileWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  const SwitchPreferenceTileWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return PreferenceTileWidget(
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeThumbColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

class DropdownPreferenceTileWidget<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  const DropdownPreferenceTileWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.items,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return PreferenceTileWidget(
      title: title,
      subtitle: subtitle,
      enabled: enabled,
      trailing: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: enabled ? onChanged : null,
        underline: Container(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
        dropdownColor: Theme.of(context).cardColor,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class TimePreferenceTileWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay>? onChanged;
  final bool enabled;

  const TimePreferenceTileWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.time,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return PreferenceTileWidget(
      title: title,
      subtitle: subtitle ?? time.format(context),
      enabled: enabled,
      trailing: const Icon(Icons.access_time, color: Colors.white70),
      onTap: enabled ? () => _selectTime(context) : null,
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != time) {
      onChanged?.call(picked);
    }
  }
}
