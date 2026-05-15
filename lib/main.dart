import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/api/api_client.dart';
import 'features/session/bloc/session_bloc.dart';
import 'features/session/data/session_repository.dart';
import 'features/session/ui/session_page.dart';
import 'features/venues/bloc/venues_bloc.dart';
import 'features/venues/data/venues_repository.dart';

void main() {
  runApp(const JumpaSiniApp());
}

class JumpaSiniApp extends StatelessWidget {
  const JumpaSiniApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => SessionRepository(apiClient)),
        RepositoryProvider(create: (_) => VenuesRepository(apiClient)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SessionBloc(context.read<SessionRepository>()),
          ),
          BlocProvider(
            create: (context) => VenuesBloc(context.read<VenuesRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'JumpaSini',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1B5E20),
            ),
            useMaterial3: true,
          ),
          home: const SessionPage(),
        ),
      ),
    );
  }
}
