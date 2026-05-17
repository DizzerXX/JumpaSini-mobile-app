import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../venue/presentation/pages/venues_page.dart';
import '../bloc/session_bloc.dart';

class SessionPage extends StatefulWidget {
  final String shortCode;

  const SessionPage({super.key, required this.shortCode});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<SessionBloc>()
        .add(CalculateMidpointEvent(widget.shortCode));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: BlocListener<SessionBloc, SessionState>(
        listener: (context, state) {
          if (state is MidpointCalculated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => VenuesPage(
                  shortCode: state.shortCode,
                  midpointLat: state.lat,
                  midpointLng: state.lng,
                ),
              ),
            );
          } else if (state is SessionError) {
            // Error is shown in the builder below — no nav needed
          }
        },
        child: BlocBuilder<SessionBloc, SessionState>(
          builder: (context, state) {
            if (state is SessionError) {
              return _ErrorView(
                message: state.message,
                onRetry: () => context
                    .read<SessionBloc>()
                    .add(CalculateMidpointEvent(widget.shortCode)),
              );
            }
            return const _LoadingView();
          },
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 24),
          Text(
            AppStrings.calculatingSpot,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
