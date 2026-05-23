import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/permission_handler.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/session_bloc.dart';
import '../widgets/location_permission_dialog.dart';
import 'add_location_page.dart';
import 'add_participants_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _joinSession(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<SessionBloc>().add(GetSessionEvent(_codeController.text.trim().toUpperCase()));
  }

  Future<void> _handleStartTap(BuildContext context) async {
    final granted = await LocationPermissionHandler.isGranted();
    if (!granted && context.mounted) {
      final permanentlyDenied =
          await LocationPermissionHandler.isPermanentlyDenied();
      if (context.mounted) {
        await showDialog<bool>(
          context: context,
          builder: (_) => LocationPermissionDialog(
            isPermanentlyDenied: permanentlyDenied,
          ),
        );
      }
    }
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AddLocationPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<SessionBloc, SessionState>(
        listener: (context, state) {
          if (state is SessionLoaded) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AddParticipantsPage(
                  session: state.session,
                  isJoining: true,
                ),
              ),
            );
          } else if (state is SessionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _Logo(),
                const SizedBox(height: 48),
                _StartButton(onPressed: () => _handleStartTap(context)),
                const SizedBox(height: 24),
                _DividerRow(),
                const SizedBox(height: 24),
                _JoinForm(
                  formKey: _formKey,
                  controller: _codeController,
                  onJoin: () => _joinSession(context),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          AppStrings.tagline,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StartButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          AppStrings.startMeetup,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _DividerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: TextStyle(color: AppColors.textSecondary)),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}

class _JoinForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final VoidCallback onJoin;

  const _JoinForm({
    required this.formKey,
    required this.controller,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: AppStrings.sessionCodeHint,
              labelText: AppStrings.enterSessionCode,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            validator: Validators.sessionCode,
          ),
          const SizedBox(height: 12),
          BlocBuilder<SessionBloc, SessionState>(
            builder: (context, state) {
              final loading = state is SessionLoading;
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: loading ? null : onJoin,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          AppStrings.joinSession,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
