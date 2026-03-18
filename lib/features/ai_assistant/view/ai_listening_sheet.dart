// ignore_for_file: deprecated_member_use
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financy_ui/features/ai_assistant/cubit/ai_settings_cubit.dart';
import 'package:financy_ui/features/ai_assistant/repo/ai_control.dart';
import 'package:financy_ui/features/ai_assistant/view/ai_settings_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum _DefaultAccountDialogAction { exit, settings }

class AiListeningSheet extends StatefulWidget {
  final BuildContext? parentContext;
  const AiListeningSheet({super.key, this.parentContext});

  @override
  State<AiListeningSheet> createState() => _AiListeningSheetState();
}

class _AiListeningSheetState extends State<AiListeningSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AIControlService _aiControl = AIControlService();
  bool _isListening = false;
  String _lastCommand = '';

  Future<void> _handleProcessInput(String text) async {
    // Lưu lại context ổn định (parent hoặc root navigator) trước khi await.
    // Nếu AiListeningSheet bị đóng (unmounted), ta vẫn có context cha để hiện bottom sheet xác nhận.
    final stableContext = widget.parentContext ?? context;

    final result = await _aiControl.processInput(text);

    // Không kiểm tra !mounted ở đây để tiếp tục xử lý ngay cả khi sheet AI đã đóng
    if (result == null) return;

    // Hiển thị kết quả xử lý
    if (!mounted) {
      log('[AI Assistant] Listening sheet closed. Showing confirmation on parent context.');
    }

    if (result.confirmMessage != null &&
        result.confirmMessage!.trim().isNotEmpty) {
      final confirm = await showModalBottomSheet<bool>(
        context: stableContext,
        backgroundColor: Theme.of(stableContext).cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (confirmSheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(confirmSheetContext).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Xác nhận giao dịch',
                    style: Theme.of(confirmSheetContext).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    result.confirmMessage!,
                    style: Theme.of(confirmSheetContext).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(confirmSheetContext).pop(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              Navigator.of(confirmSheetContext).pop(true),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Xác nhận'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (confirm == true) {
        // Luôn sử dụng stableContext để gọi confirmTransaction (nơi truy cập Bloc/Cubit)
        final success = await _aiControl.confirmTransaction(
          stableContext,
          result,
        );
        if (success && result.message != null && result.message!.isNotEmpty) {
          await _aiControl.speakText(result.message);
        }
      }
    } else {
      final success = await _aiControl.confirmTransaction(stableContext, result);
      if (success && result.message != null && result.message!.isNotEmpty) {
        await _aiControl.speakText(result.message);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _ensureMicrophonePermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDefaultAccountConfigured();
    });
  }

  Future<void> _checkDefaultAccountConfigured() async {
    final aiSettingsCubit = context.read<AiSettingsCubit>();

    // Load settings if not already loaded
    if (aiSettingsCubit.state.isLoading) {
      await aiSettingsCubit.loadSettings();
    }

    final hasDefaultAccount = aiSettingsCubit.hasDefaultAccount;
    if (hasDefaultAccount || !mounted) {
      return;
    }

    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final action = await showDialog<_DefaultAccountDialogAction>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Chua cai dat tai khoan mac dinh'),
            content: const Text(
              'Ban can chon tai khoan mac dinh de AI co the tao giao dich dung nguon tien.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop(_DefaultAccountDialogAction.exit);
                },
                child: const Text('Thoat'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(
                    dialogContext,
                  ).pop(_DefaultAccountDialogAction.settings);
                },
                child: const Text('Cai dat'),
              ),
            ],
          ),
    );

    if (!mounted || action == null) {
      return;
    }

    if (action == _DefaultAccountDialogAction.exit) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pop();
    rootNavigator.push(
      MaterialPageRoute(builder: (_) => const AiSettingsScreen()),
    );
  }

  Future<void> _ensureMicrophonePermission() async {
    var status = await Permission.microphone.status;

    if (status.isGranted) {
      await _startListening();
      return;
    }

    status = await Permission.microphone.request();

    if (!mounted) {
      return;
    }

    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Microphone permission is required for AI Assistant',
          ),
          action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
        ),
      );
      return;
    }

    if (status.isGranted) {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (_isListening || !mounted) return;
    _lastCommand = '';

    final isAvailable = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'notListening') {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
        });
      },
    );

    if (!isAvailable || !mounted) return;

    setState(() {
      _isListening = true;
    });
    log('Bat dau nghe...');

    await _speech.listen(
      localeId: 'vi_VN',
      // listenFor: const Duration(minutes: 5),
      // pauseFor: const Duration(minutes: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
      onResult: (result) async {
        if (!mounted) return;

        _lastCommand = result.recognizedWords.trim();

        if (result.finalResult) {
          final text = _lastCommand;
          if (text.isEmpty) return;

          setState(() {
            _isListening = false;
          });

          // Explicitly stop speech to release audio focus before TTS
          await _speech.stop();
          await Future.delayed(const Duration(milliseconds: 500));

          await _handleProcessInput(text);

          if (!mounted) return;
          setState(() {});
        }
      },
    );
  }

  Future<void> _stopListening() async {
    if (!_speech.isListening) return;
    await _speech.stop();
    if (!mounted) return;

    setState(() {
      _isListening = false;
    });

    if (_lastCommand.isNotEmpty) {
      setState(() {});
      await _handleProcessInput(_lastCommand);
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.22),
            primary.withValues(alpha: 0.5),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: primary.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                if (_isListening) {
                  await _stopListening();
                } else {
                  await _startListening();
                }
              },
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final pulse = 1 + (_controller.value * 0.25);

                  return Transform.scale(
                    scale: pulse,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.primaryColor.withValues(alpha: 0.14),
                      ),
                      child: Center(
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withValues(
                                  alpha: 0.45,
                                ),
                                blurRadius: 24,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: theme.colorScheme.onPrimary,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // const SizedBox(height: 22),

            // Text(
            //   'AI Assistant',
            //   style: theme.textTheme.titleLarge?.copyWith(
            //     fontWeight: FontWeight.w800,
            //     letterSpacing: 0.2,
            //     color: Colors.white.withValues(alpha: 0.9),
            //   ),
            // ),
            // const SizedBox(height: 6),
            // Text(
            //   _isProcessing
            //       ? 'Dang xu ly noi dung...'
            //       : 'Xin chao! Toi dang lang nghe ban...',
            //   style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
            //   textAlign: TextAlign.center,
            // ),
          ],
        ),
      ),
    );
  }
}
