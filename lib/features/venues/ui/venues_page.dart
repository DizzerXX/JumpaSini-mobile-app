import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/venues_bloc.dart';

class VenuesPage extends StatelessWidget {
  final String sessionCode;

  const VenuesPage({super.key, required this.sessionCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Venues')),
      body: BlocBuilder<VenuesBloc, VenuesState>(
        builder: (context, state) {
          if (state is VenuesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VenuesError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is VenuesLoaded) {
            return ListView.builder(
              itemCount: state.venues.length,
              itemBuilder: (context, index) {
                final venue = state.venues[index];
                return ListTile(
                  title: Text(venue['name'] as String? ?? ''),
                  subtitle: Text(venue['address'] as String? ?? ''),
                );
              },
            );
          }
          return const Center(child: Text('Venues Page — UI coming soon'));
        },
      ),
    );
  }
}
