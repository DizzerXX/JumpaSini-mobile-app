import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/di/injection_container.dart' as di;
import 'features/session/presentation/bloc/session_bloc.dart';
import 'features/session/presentation/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  di.setup();
  runApp(const JumpaSiniApp());
}

class JumpaSiniApp extends StatelessWidget {
  const JumpaSiniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionBloc>(create: (_) => di.sl<SessionBloc>()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            primaryContainer: AppColors.primaryContainer,
            onPrimaryContainer: AppColors.textPrimary,
            secondary: AppColors.secondary,
            onSecondary: AppColors.textPrimary,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
            error: AppColors.error,
            onError: Colors.white,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          chipTheme: ChipThemeData(
            selectedColor: AppColors.primary,
            labelStyle: const TextStyle(color: AppColors.textPrimary),
            secondaryLabelStyle: const TextStyle(color: Colors.white),
            backgroundColor: AppColors.chipUnselected,
            secondarySelectedColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}
