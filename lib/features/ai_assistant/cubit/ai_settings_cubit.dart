import 'package:financy_ui/features/Account/models/money_source.dart';
import 'package:financy_ui/features/ai_assistant/cubit/ai_settings_state.dart';
import 'package:financy_ui/features/ai_assistant/models/AI_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class AiSettingsCubit extends Cubit<AiSettingsState> {
  AiSettingsCubit() : super(AiSettingsState.initial());

  Future<void> _persistSettings(AiSettings settings) async {
    try {
      emit(state.copyWith(isSaving: true, error: null));
      final settingsBox =
          Hive.isBoxOpen('aiSettingsBox')
              ? Hive.box<AiSettings>('aiSettingsBox')
              : await Hive.openBox<AiSettings>('aiSettingsBox');

      await settingsBox.put('settings', settings);
      emit(state.copyWith(isSaving: false));
    } catch (e) {
      emit(
        state.copyWith(isSaving: false, error: 'Failed to save settings: $e'),
      );
    }
  }

  Future<void> loadSettings() async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      final settingsBox =
          Hive.isBoxOpen('aiSettingsBox')
              ? Hive.box<AiSettings>('aiSettingsBox')
              : await Hive.openBox<AiSettings>('aiSettingsBox');

      final moneySourceBox =
          Hive.isBoxOpen('moneySourceBox')
              ? Hive.box<MoneySource>('moneySourceBox')
              : await Hive.openBox<MoneySource>('moneySourceBox');

      final saved = settingsBox.get('settings');
      final activeSources =
          moneySourceBox.values.where((source) => source.isActive).toList();

      emit(
        state.copyWith(
          isLoading: false,
          settings: saved ?? AiSettings(),
          activeMoneySources: activeSources,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load settings: $e',
          settings: AiSettings(),
        ),
      );
    }
  }

  Future<void> toggleConfirm(bool value) async {
    try {
      final updated = state.settings.copyWith(isConfirm: value);
      emit(state.copyWith(settings: updated, error: null));
      await _persistSettings(updated);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update confirmation: $e'));
    }
  }

  Future<void> setDefaultMoneySourceById(String? selectedId) async {
    try {
      MoneySource? selected;
      for (final source in state.activeMoneySources) {
        if ((source.id ?? source.name) == selectedId) {
          selected = source;
          break;
        }
      }

      final updated = state.settings.copyWith(defaultMoneySource: selected);
      emit(state.copyWith(settings: updated, error: null));
      await _persistSettings(updated);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to update money source: $e'));
    }
  }

  Future<void> refreshMoneySources() async {
    try {
      final moneySourceBox =
          Hive.isBoxOpen('moneySourceBox')
              ? Hive.box<MoneySource>('moneySourceBox')
              : await Hive.openBox<MoneySource>('moneySourceBox');

      final activeSources =
          moneySourceBox.values.where((source) => source.isActive).toList();
      emit(state.copyWith(activeMoneySources: activeSources, error: null));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to refresh money sources: $e'));
    }
  }

  Future<bool> saveSettings() async {
    try {
      if (state.isSaving) return false;
      await _persistSettings(state.settings);
      return true;
    } catch (e) {
      emit(state.copyWith(error: 'Failed to save settings: $e'));
      return false;
    }
  }

  bool get hasDefaultAccount => state.settings.defaultMoneySource != null;

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
