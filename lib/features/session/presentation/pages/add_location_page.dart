import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../bloc/session_bloc.dart';
import '../widgets/transport_mode_selector.dart';
import '../widgets/venue_type_selector.dart';
import 'add_participants_page.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({super.key});

  @override
  State<AddLocationPage> createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  String? _transportMode;
  String? _venueType;
  bool _halalOnly = true;

  bool get _canProceed => _transportMode != null && _venueType != null;

  void _onNext(BuildContext context) {
    if (!_canProceed) return;
    context.read<SessionBloc>().add(
          CreateSessionEvent(
            transportMode: _transportMode!,
            venueType: _venueType!,
            halalFilter: _halalOnly,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.setupMeetup),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<SessionBloc, SessionState>(
        listener: (context, state) {
          if (state is SessionCreated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => AddParticipantsPage(session: state.session),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel(AppStrings.howWillYouTravel),
              const SizedBox(height: 12),
              TransportModeSelector(
                selectedMode: _transportMode,
                onChanged: (mode) => setState(() => _transportMode = mode),
              ),
              const SizedBox(height: 32),
              const _SectionLabel(AppStrings.whatAreYouLookingFor),
              const SizedBox(height: 12),
              VenueTypeSelector(
                selectedType: _venueType,
                onChanged: (type) => setState(() => _venueType = type),
              ),
              const SizedBox(height: 32),
              SwitchListTile(
                value: _halalOnly,
                onChanged: (v) => setState(() => _halalOnly = v),
                title: const Text(
                  AppStrings.halalOnly,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                activeThumbColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),
              BlocBuilder<SessionBloc, SessionState>(
                builder: (context, state) {
                  final loading = state is SessionLoading;
                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_canProceed && !loading) ? () => _onNext(context) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.border,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              AppStrings.next,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}
