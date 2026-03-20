import 'dart:developer';
import 'dart:convert';
import 'package:financy_ui/app/services/Server/dio_client.dart';
import 'package:financy_ui/features/ai_assistant/models/AI_settings.dart';
import 'package:financy_ui/features/ai_assistant/models/AI_result_models.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financy_ui/features/transactions/Cubit/transactionCubit.dart';
import 'package:financy_ui/features/Account/cubit/manageMoneyCubit.dart';
import 'package:financy_ui/features/Users/Cubit/userCubit.dart';
import 'package:financy_ui/features/ai_assistant/cubit/ai_settings_cubit.dart';
import 'package:financy_ui/features/transactions/models/transactionsModels.dart';
import 'package:financy_ui/features/Account/models/money_source.dart';
import 'package:financy_ui/shared/utils/generateID.dart';
import 'package:hive/hive.dart';

abstract class AiControl {
  Future<AiResultModels?> processInput(String input);
  Future<bool> confirmTransaction(BuildContext context, AiResultModels result);
  Future<void> speakText(String? text);
}

class AIControlService implements AiControl {
  final FlutterTts _tts = FlutterTts();
  bool _ttsConfigured = false;
  void Function(String message)? onLog;

  void _logger(String message) {
    log(message);
    onLog?.call(message);
  }

  AIControlService() {
    _initTts();
  }

  Future<void> _initTts() async {
    if (_ttsConfigured) return;
    try {
      // Log all available engines on Android to see what we have
      try {
        final dynamic engines = await _tts.getEngines;

        if (engines.toString().contains('com.google.android.tts')) {
          await _tts.setEngine('com.google.android.tts');
        }
      } catch (_) {}

      final dynamic isAvailable = await _tts.isLanguageAvailable('vi-VN');
      _logger('[TTS] vi-VN language availability: $isAvailable');

      await _tts.setLanguage('vi-VN');

      // Configuration for iOS/Real devices
      try {
        await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        ]);
        await _tts.setSharedInstance(true);
      } catch (e) {
        _logger('[TTS] setIosAudioCategory notice: $e');
      }

      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
      _ttsConfigured = true;

      _logger('[TTS] Configuration complete');
      // Test speak during init (optional, let's skip to not annoy user)
    } catch (e) {
      _logger('[TTS] Initialization error: $e');
    }
  }

  @override
  Future<void> speakText(String? text) async {
    final content = (text ?? '').trim();
    if (content.isEmpty) return;

    try {
      if (!_ttsConfigured) {
        await _initTts();
      }

      await _tts.stop();
      final result = await _tts.speak(content);
      _logger('[TTS] Speak called for: $content, Result: $result');
    } catch (e) {
      _logger('[TTS] speakText error: $e');
    }
  }

  @override
  Future<AiResultModels?> processInput(String input) async {
    try {
      final text = input.trim();
      if (text.isEmpty) {
        return null;
      }

      log('[AI Assistant] Speech input: $text');

      AiResultModels? latestResult;
      String? currentEvent;
      String? currentMessageEvent;
      final dataBuffer = StringBuffer();

      Future<void> handlePayload(String payload) async {
        if (payload.trim().isEmpty) return;

        try {
          final decoded = jsonDecode(payload);
          if (decoded is! Map<String, dynamic>) return;

          final event =
              (decoded['event'] ?? currentEvent ?? 'message').toString();
          final messageEvent =
              (decoded['messageEvent'] ?? currentMessageEvent ?? '').toString();

          final data = decoded['data'];
          Map<String, dynamic>? dataMap;
          if (data is Map<String, dynamic>) {
            dataMap = data;
          } else if (decoded['intent'] != null || decoded['entities'] != null) {
            dataMap = decoded;
          }

          if (dataMap != null) {
            try {
              latestResult = AiResultModels.fromJson(dataMap);
            } catch (_) {
              // Ignore parse errors for intermediate chunks.
            }
          }

          log(
            '[AI SSE] event=$event | messageEvent=$messageEvent | data=${dataMap ?? decoded}',
          );

          if (messageEvent.isNotEmpty) {
            await speakText(messageEvent);
            await Future.delayed(const Duration(seconds: 2));
          }

          final confirmMessage =
              (dataMap?['confirmMessage'] ?? decoded['confirmMessage'] ?? '')
                  .toString();
          if (confirmMessage.trim().isNotEmpty) {
            await speakText(confirmMessage);
          }
        } catch (_) {
          log('[AI SSE] raw=$payload');
        }
      }

      Future<void> flushFrame() async {
        if (dataBuffer.isNotEmpty) {
          await handlePayload(dataBuffer.toString());
        }
        dataBuffer.clear();
        currentEvent = null;
        currentMessageEvent = null;
      }

      final aiSettingsBox =
          Hive.isBoxOpen('aiSettingsBox')
              ? Hive.box<AiSettings>('aiSettingsBox')
              : await Hive.openBox<AiSettings>('aiSettingsBox');
      final aiSettings = aiSettingsBox.get('settings');
      final isConfirm = aiSettings?.isConfirm ?? true;

      log('[AI Assistant] Sending to AI: "$text"');

      final body = await ApiService().postStream(
        '/ai/detect',
        data: AIRequest(userInput: text, isConfirm: isConfirm).toJson(),
      );

      await for (final line in body.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        final trimmed = line.trim();

        if (trimmed.isEmpty) {
          await flushFrame();
          continue;
        }

        if (trimmed.startsWith('event:')) {
          currentEvent = trimmed.substring(6).trim();
          continue;
        }

        if (trimmed.startsWith('messageEvent:')) {
          currentMessageEvent = trimmed.substring(13).trim();
          continue;
        }

        if (trimmed.startsWith('data:')) {
          if (dataBuffer.isNotEmpty) {
            dataBuffer.write('\n');
          }
          dataBuffer.write(trimmed.substring(5).trim());
          continue;
        }

        if (trimmed.startsWith('{')) {
          await handlePayload(trimmed);
        }
      }

      await flushFrame();
      return latestResult;
    } catch (e) {
      log('[AI SSE] processInput error: $e');
      await speakText('Phát sinh lỗi kết nối');
      return null;
    }
  }

  @override
  Future<bool> confirmTransaction(BuildContext context, AiResultModels result) async {
    try {
      final aiSettingsCubit = context.read<AiSettingsCubit>();
      final userCubit = context.read<UserCubit>();
      final transactionCubit = context.read<TransactionCubit>();
      final manageMoneyCubit = context.read<ManageMoneyCubit>();
      
      final defaultAccount = aiSettingsCubit.state.settings.defaultMoneySource;

      if (defaultAccount == null) {
        log('[AI Assistant] No default account set');
        await speakText('Vui lòng cài đặt tài khoản để lưu giao dịch');
        return false;
      }

      // Lấy thông tin tài khoản mới nhất từ ManageMoneyCubit để tránh dùng balance cũ (stale balance)
      final latestAccount = (manageMoneyCubit.listAccounts ?? []).firstWhere(
        (e) => (e.id ?? e.name) == (defaultAccount.id ?? defaultAccount.name),
        orElse: () => defaultAccount,
      );

      final uid = userCubit.state.user?.uid ?? '';

      DateTime parsedDate;
      try {
        parsedDate = result.entities.date.isNotEmpty 
          ? DateTime.parse(result.entities.date) 
          : DateTime.now();
      } catch (e) {
        parsedDate = DateTime.now();
      }

      final amount = result.entities.amount;
      log('[AI Assistant] Creating transaction: amount=$amount, note=${result.entities.note}');

      final transaction = Transactionsmodels(
        id: GenerateID.newID(),
        uid: uid,
        accountId: latestAccount.id ?? latestAccount.name,
        categoriesId: result.category?.name ?? '',
        type: result.intent,
        amount: amount,
        note: result.entities.note,
        transactionDate: parsedDate,
        createdAt: DateTime.now(),
        pendingSync: false,
      );

      // Save transaction and update state
      await transactionCubit.addTransaction(transaction);

      // Update account balance correctly using the freshest balance
      double newBalance = latestAccount.balance;
      if (result.intent == TransactionType.income) {
        newBalance += amount;
      } else {
        newBalance -= amount;
      }

      final updatedAccount = MoneySource(
        id: latestAccount.id,
        uid: latestAccount.uid,
        name: latestAccount.name,
        balance: newBalance,
        type: latestAccount.type,
        currency: latestAccount.currency,
        iconCode: latestAccount.iconCode,
        color: latestAccount.color,
        description: latestAccount.description,
        isActive: latestAccount.isActive,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
      );

      await manageMoneyCubit.updateAccount(updatedAccount);

      log(
        '[AI Assistant] Transaction confirmed: intent=${result.intent}, note=${result.entities.note}, amount=$amount, newBalance=$newBalance, date=$parsedDate, Category: ${result.category?.name}',
      );
      return true;
    } catch (e) {
      log('[AI Assistant] confirmTransaction error: $e');
      await speakText('Có lỗi phát sinh');
      return false;
    }
  }
}

