// ignore_for_file: file_names

import 'package:financy_ui/features/Account/cubit/manageMoneyCubit.dart';
import 'package:financy_ui/features/transactions/view/add.dart';
import 'package:financy_ui/features/Users/Cubit/userCubit.dart';
import 'package:financy_ui/features/transactions/view/home.dart';
import 'package:financy_ui/features/notification/cubit/notificationCubit.dart';
import 'package:financy_ui/features/Setting/settings.dart';
import 'package:financy_ui/features/transactions/view/statiscal.dart';
import 'package:financy_ui/features/transactions/view/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financy_ui/l10n/app_localizations.dart';
import 'package:financy_ui/features/auth/cubits/authCubit.dart';
import 'package:financy_ui/features/auth/cubits/authState.dart';
import 'package:financy_ui/app/services/Local/settings_service.dart';
import 'package:financy_ui/features/Sync/services/background_sync_service.dart';
import 'package:financy_ui/core/utils/logger.dart';
import 'package:financy_ui/features/ai_assistant/view/ai_listening_sheet.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isAddMenuOpen = false;
  late final AnimationController _menuController;
  late final Animation<double> _manualOptionAnimation;
  late final Animation<double> _aiOptionAnimation;

  int get _bottomNavIndex =>
      _currentIndex >= 2 ? _currentIndex + 1 : _currentIndex;

  void _openAddMenu() {
    setState(() {
      _isAddMenuOpen = true;
    });
    _menuController.forward(from: 0);
  }

  Future<void> _closeAddMenu() async {
    await _menuController.reverse();
    if (!mounted) return;
    setState(() {
      _isAddMenuOpen = false;
    });
  }

  void _toggleBottomNavigationBar(int index) {
    if (index == 2) {
      if (_isAddMenuOpen) {
        _closeAddMenu();
      } else {
        _openAddMenu();
      }
      return;
    }

    setState(() {
      _currentIndex = index > 2 ? index - 1 : index;
    });

    if (_isAddMenuOpen) {
      _closeAddMenu();
    }
  }

  void _openManualAdd() {
    _closeAddMenu().then((_) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddTransactionScreen()),
      );
    });
  }

  void _openAiAssistant() {
    _closeAddMenu().then((_) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => AiListeningSheet(parentContext: context),
      );
    });
  }

  final List<Widget> _pages = [Home(), Wallet(), Statiscal(), Settings()];

  @override
  void initState() {
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _manualOptionAnimation = CurvedAnimation(
      parent: _menuController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      reverseCurve: Curves.easeInCubic,
    );
    _aiOptionAnimation = CurvedAnimation(
      parent: _menuController,
      curve: const Interval(0.22, 1.0, curve: Curves.easeOutBack),
      reverseCurve: Curves.easeInCubic,
    );

    context.read<UserCubit>().getUser();
    context.read<ManageMoneyCubit>().getAllAccount();
    context.read<NotificationCubit>().loadNotificationSettings();

    // Start background sync if user is logged in with Google
    if (!SettingsService.isGuestLogin()) {
      debugLog('Starting background sync on app start');
      BackgroundSyncService.startBackgroundSync()
          .then((_) {
            debugLog('Background sync initiated');
          })
          .catchError((e) {
            debugLog('Failed to start background sync: $e');
          });
    }

    super.initState();
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocal = AppLocalizations.of(context);
    return BlocListener<Authcubit, Authstate>(
      listener: (context, state) {
        if (state.authStatus == AuthStatus.error ||
            state.authStatus == AuthStatus.unAuthenticated) {
          Navigator.pushNamed(context, '/login');
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(child: _pages[_currentIndex]),
            if (_isAddMenuOpen)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _menuController,
                  builder:
                      (_, __) => GestureDetector(
                        onTap: _closeAddMenu,
                        child: Container(
                          color: Colors.black.withValues(
                            alpha: 0.08 + (_menuController.value * 0.14),
                          ),
                        ),
                      ),
                ),
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              left: 0,
              right: 0,
              bottom: _isAddMenuOpen ? 20 : -140,
              child: IgnorePointer(
                ignoring: !_isAddMenuOpen,
                child: AnimatedBuilder(
                  animation: _menuController,
                  builder: (_, __) {
                    final manualSlide = (1 - _manualOptionAnimation.value) * 30;
                    final aiSlide = (1 - _aiOptionAnimation.value) * 30;
                    final menuOpacity = _menuController.value.clamp(0.0, 1.0);
                    final manualOpacity = _manualOptionAnimation.value.clamp(
                      0.0,
                      1.0,
                    );
                    final aiOpacity = _aiOptionAnimation.value.clamp(0.0, 1.0);

                    return Opacity(
                      opacity: menuOpacity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.translate(
                            offset: Offset(0, manualSlide),
                            child: Transform.scale(
                              scale:
                                  0.92 + (_manualOptionAnimation.value * 0.08),
                              child: Opacity(
                                opacity: manualOpacity,
                                child: _AddOptionButton(
                                  icon: Icons.edit_rounded,
                                  label: 'Thủ công',
                                  color: theme.colorScheme.primary,
                                  onTap: _openManualAdd,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Transform.translate(
                            offset: Offset(0, aiSlide),
                            child: Transform.scale(
                              scale: 0.92 + (_aiOptionAnimation.value * 0.08),
                              child: Opacity(
                                opacity: aiOpacity,
                                child: _AddOptionButton(
                                  icon: Icons.mic_rounded,
                                  label: 'AI Assistant',
                                  color: theme.colorScheme.tertiary,
                                  onTap: _openAiAssistant,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor:
              theme.bottomNavigationBarTheme.unselectedItemColor,
          currentIndex: _bottomNavIndex,
          onTap: _toggleBottomNavigationBar,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.timeline),
              label: appLocal?.transactionBook ?? 'Transaction Book',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet),
              label: appLocal?.wallet ?? 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.bottomNavigationBarTheme.selectedItemColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: theme.bottomNavigationBarTheme.backgroundColor,
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart),
              label: appLocal?.statistics ?? 'Statistics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: appLocal?.settings ?? 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class _AddOptionButton extends StatelessWidget {
  const _AddOptionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              // const SizedBox(width: 10),
              // Text(
              //   label,
              //   style: theme.textTheme.labelLarge?.copyWith(
              //     fontWeight: FontWeight.w700,
              //     letterSpacing: 0.15,
              //     color: colorScheme.onSurface,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
