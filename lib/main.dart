import 'package:chat_app/services/Auth_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();

  runApp(
    MyApp(),
  );
}

Future<void> setup() async {
  await setupFirebase();
  await registerServices();
}

class MyApp extends StatelessWidget {
  final GetIt _getIt =GetIt.instance;
  late NavigationService _navigationService;
  late AuthService _authService;
  
    MyApp({super.key}){
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();

   }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigationService.navigatorKey,
      title: 'Chat App',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
         debugShowCheckedModeBanner: false, 
      initialRoute: _authService.user != null ? "/home" : "/login",
      routes: _navigationService.routes!,
    );
  }
}