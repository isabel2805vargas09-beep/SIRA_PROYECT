import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/supabase_config.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const SiraApp());
}

class SiraApp extends StatelessWidget {
  const SiraApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      title:'SIRA Web',
      locale:const Locale('es'),
      supportedLocales:const [Locale('es')],
      localizationsDelegates:const [GlobalMaterialLocalizations.delegate,GlobalWidgetsLocalizations.delegate,GlobalCupertinoLocalizations.delegate],
      theme:ThemeData(useMaterial3:true,scaffoldBackgroundColor:const Color(0xFFFFF7FB),textTheme:GoogleFonts.dmSansTextTheme(),colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xFFC20D78))),
      home:const LoginScreen(),
    );
  }
}
