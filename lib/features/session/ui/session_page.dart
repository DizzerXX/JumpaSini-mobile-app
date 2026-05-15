import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/session_bloc.dart';

class SessionPage extends StatelessWidget {
  const SessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JumpaSini')),
      body: BlocConsumer<SessionBloc, SessionState>(
        listener: (context, state) {
          if (state is SessionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SessionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SessionCreated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Session created!'),
                  Text('Code: ${state.sessionCode}'),
                  Text('Link: ${state.shareLink}'),
                ],
              ),
            );
          }
          return const Center(child: Text('Session Page — UI coming soon'));
        },
      ),
    );
  }
}
