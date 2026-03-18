import 'package:financy_ui/features/Account/models/money_source.dart';
import 'package:financy_ui/features/ai_assistant/models/AI_settings.dart';

class AiSettingsState {
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final AiSettings settings;
  final List<MoneySource> activeMoneySources;

  const AiSettingsState({
    required this.isLoading,
    required this.isSaving,
    this.error,
    required this.settings,
    required this.activeMoneySources,
  });

  factory AiSettingsState.initial() {
    return AiSettingsState(
      isLoading: true,
      isSaving: false,
      error: null,
      settings: AiSettings(),
      activeMoneySources: const [],
    );
  }

  AiSettingsState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    AiSettings? settings,
    List<MoneySource>? activeMoneySources,
  }) {
    return AiSettingsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      settings: settings ?? this.settings,
      activeMoneySources: activeMoneySources ?? this.activeMoneySources,
    );
  }
}
