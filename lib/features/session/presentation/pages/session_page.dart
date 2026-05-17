import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../venue/presentation/bloc/venue_bloc.dart';
import '../../../venue/presentation/pages/recommendation_page.dart';
import '../bloc/session_bloc.dart';

class SessionPage extends StatefulWidget {
  final String shortCode;

  const SessionPage({super.key, required this.shortCode});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  late final VenueBloc _venueBloc;
  double? _midpointLat;
  double? _midpointLng;
  String? _errorMessage;
  bool _isVenueError = false;

  @override
  void initState() {
    super.initState();
    _venueBloc = sl<VenueBloc>();
    context.read<SessionBloc>().add(CalculateMidpointEvent(widget.shortCode));
  }

  @override
  void dispose() {
    _venueBloc.close();
    super.dispose();
  }

  void _retry() {
    setState(() => _errorMessage = null);
    if (_isVenueError && _midpointLat != null) {
      _venueBloc.add(LoadRecommendationEvent(widget.shortCode));
    } else {
      context
          .read<SessionBloc>()
          .add(CalculateMidpointEvent(widget.shortCode));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _venueBloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.appName),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<SessionBloc, SessionState>(
              listener: (context, state) {
                if (state is MidpointCalculated) {
                  _midpointLat = state.lat;
                  _midpointLng = state.lng;
                  _venueBloc.add(
                    LoadRecommendationEvent(state.shortCode),
                  );
                } else if (state is SessionError) {
                  setState(() {
                    _errorMessage = state.message;
                    _isVenueError = false;
                  });
                }
              },
            ),
            BlocListener<VenueBloc, VenueState>(
              listener: (context, state) {
                if (state is RecommendationLoaded) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => RecommendationPage(
                        recommendation: state.recommendation,
                        shortCode: widget.shortCode,
                        midpointLat: _midpointLat!,
                        midpointLng: _midpointLng!,
                      ),
                    ),
                  );
                } else if (state is VenueError) {
                  setState(() {
                    _errorMessage = state.message;
                    _isVenueError = true;
                  });
                }
              },
            ),
          ],
          child: _errorMessage != null
              ? _ErrorView(message: _errorMessage!, onRetry: _retry)
              : const _LoadingView(),
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
