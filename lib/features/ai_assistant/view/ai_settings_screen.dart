import 'package:financy_ui/features/ai_assistant/cubit/ai_settings_cubit.dart';
import 'package:financy_ui/features/ai_assistant/cubit/ai_settings_state.dart';
import 'package:financy_ui/features/ai_assistant/models/AI_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  String? _selectedSourceId(AiSettings settings) {
    final selected = settings.defaultMoneySource;
    if (selected == null) return null;
    return selected.id ?? selected.name;
  }

  String? _effectiveSelectedSourceId(AiSettingsState state) {
    final selectedId = _selectedSourceId(state.settings);
    if (selectedId == null) return null;

    final exists = state.activeMoneySources.any(
      (source) => (source.id ?? source.name) == selectedId,
    );
    return exists ? selectedId : null;
  }

  @override
  void initState() {
    super.initState();
    context.read<AiSettingsCubit>().loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'AI Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.15,
          ),
        ),
      ),
      body: BlocBuilder<AiSettingsCubit, AiSettingsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error if any
          if (state.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: 'Dismiss',
                    onPressed: () {
                      context.read<AiSettingsCubit>().clearError();
                    },
                  ),
                ),
              );
            });
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: colorScheme.surfaceContainerLow,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: SwitchListTile(
                  value: state.settings.isConfirm,
                  onChanged: (value) {
                    context.read<AiSettingsCubit>().toggleConfirm(value);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Saved AI settings'),
                        backgroundColor: theme.primaryColor,
                        duration: const Duration(milliseconds: 900),
                      ),
                    );
                  },
                  // ignore: deprecated_member_use
                  activeColor: theme.primaryColor,
                  title: Text(
                    'Require confirmation before AI action',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Turn on to review AI generated transaction before saving.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: colorScheme.surfaceContainerLow,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Default money source',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String?>(
                        isExpanded: true,
                        // ignore: deprecated_member_use
                        value: _effectiveSelectedSourceId(state),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.primaryColor,
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                          hintText: 'Select a money source',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                              'No default source',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          ...state.activeMoneySources.map(
                            (source) => DropdownMenuItem<String?>(
                              value: source.id ?? source.name,
                              child: Text(
                                source.name,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          context
                              .read<AiSettingsCubit>()
                              .setDefaultMoneySourceById(value);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Saved AI settings'),
                              backgroundColor: theme.primaryColor,
                              duration: const Duration(milliseconds: 900),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'AI will preselect this source when creating transactions.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
