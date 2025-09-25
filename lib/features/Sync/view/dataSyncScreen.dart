// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:financy_ui/features/Sync/cubit/syncCubit.dart';
import 'package:financy_ui/features/Sync/cubit/syncState.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:financy_ui/app/services/Local/settings_service.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:financy_ui/features/auth/repository/authRepo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataSyncScreen extends StatefulWidget {
  const DataSyncScreen({super.key});

  @override
  State<DataSyncScreen> createState() => _DataSyncScreenState();
}

class _DataSyncScreenState extends State<DataSyncScreen> {
  bool _authLoading = false;
  // Hàm tiện ích
  String _localText(
    BuildContext context,
    String Function(AppLocalizations) getter,
  ) {
    final appLocal = AppLocalizations.of(context);
    return appLocal != null ? getter(appLocal) : '';
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _authLoading = true);
    final appLocal = AppLocalizations.of(context);
    try {
      // 1) Firebase Google sign-in (may throw if aborted)
      await Authrepo().signInWithGoogle();

      // 2) Retrieve ID token from current Firebase user
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('No ID token');
      }

      // 3) Backend login to obtain API tokens and set app state/mode
      await Authrepo().loginWithGoogle(idToken);

      // 4) Refresh UI so sync becomes enabled
      if (mounted) {
        setState(() {});
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocal?.success ?? 'Success'),
            backgroundColor: theme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final msg = appLocal?.error ?? 'Error';
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$msg: ${e.toString()}'),
          backgroundColor: theme.primaryColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _authLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _localText(context, (l) => l.dataSync),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: theme.primaryColor,
      ),
      body: BlocProvider(
        create: (context) => SyncCubit(),
        child: BlocConsumer<SyncCubit, SyncState>(
          listener: (context, state) {
            if (state is SyncSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is SyncFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final syncCubit = context.read<SyncCubit>();
            final lastSyncTime = syncCubit.getLastSyncTime();
            final formattedLastSync = DateFormat(
              'dd/MM/yyyy HH:mm',
            ).format(lastSyncTime);
            final syncEnabled = SettingsService.isSyncEnabled();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Last sync info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.access_time,
                            color: theme.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _localText(context, (l) => l.lastSync),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                formattedLastSync,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Animation / hint
                  if (state is SyncLoading)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: Lottie.asset(
                                'assets/animation/sync_animation.json',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _localText(context, (l) => l.syncingData),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: SvgPicture.asset(
                              'assets/image/sync_image.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _localText(context, (l) => l.readyToSync),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (!syncEnabled) ...[
                            const SizedBox(height: 12),
                            Text(
                              _localText(
                                context,
                                (l) => l.syncRequiresGoogleLogin,
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.orange[800],
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 260,
                              child: ElevatedButton(
                                onPressed:
                                    _authLoading ? null : _handleGoogleSignIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  elevation: 0,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (!_authLoading)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: Image.asset(
                                          'assets/image/google.png',
                                          width: 20,
                                          height: 20,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    if (_authLoading)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        _localText(
                                          context,
                                          (l) => l.continue_with_google,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.cloud_upload,
                          title: _localText(context, (l) => l.uploadData),
                          color: Colors.blue,
                          onTap:
                              state is SyncLoading || !syncEnabled
                                  ? null
                                  : () => syncCubit.syncData(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.cloud_download,
                          title: _localText(context, (l) => l.downloadData),
                          color: Colors.green,
                          onTap:
                              state is SyncLoading || !syncEnabled
                                  ? null
                                  : () => syncCubit.fetchData(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[300] : color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
