import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Cubits
import 'logic/auth_cubit/auth_cubit.dart';
import 'logic/profile_cubit/profile_cubit.dart';
import 'logic/item_cubit/item_cubit.dart';
import 'logic/favorite_cubit/favorite_cubit.dart';

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
      ],
      child: MaterialApp(
        title: 'RePlay',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: initialSession != null ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }
}
