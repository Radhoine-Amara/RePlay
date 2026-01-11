import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_dev_app_gaming/l10n/app_localizations.dart';

// Cubits
import 'logic/auth_cubit/auth_cubit.dart';
import 'logic/profile_cubit/profile_cubit.dart';
import 'logic/item_cubit/item_cubit.dart';
import 'logic/favorite_cubit/favorite_cubit.dart';
import 'logic/language_cubit/language_cubit.dart';
import 'logic/language_cubit/language_state.dart';

// Screens
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Check if a session exists
  final session = Supabase.instance.client.auth.currentSession;

  runApp(MyApp(initialSession: session));
}

class MyApp extends StatelessWidget {
  final Session? initialSession;

  const MyApp({super.key, this.initialSession});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()..checkAuthStatus()),
        BlocProvider<ProfileCubit>(create: (_) => ProfileCubit()),
        BlocProvider<ItemCubit>(create: (_) => ItemCubit()..loadAllItems()),
        BlocProvider<FavoriteCubit>(create: (_) => FavoriteCubit()),
        BlocProvider<LanguageCubit>(
          create: (_) => LanguageCubit()..loadLanguage(),
        ),
      ],
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, state) {
          Locale locale = LanguageCubit.defaultLocale;
          if (state is LanguageLoaded) {
            locale = state.locale;
          }

          return MaterialApp(
            title: 'RePlay',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LanguageCubit.supportedLocales,
            home: initialSession != null
                ? const HomeScreen()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}
