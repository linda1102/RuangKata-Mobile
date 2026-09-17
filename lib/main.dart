import 'package:flutter/material.dart';
import 'package:frontend/pages/artcilesPage.dart';
import 'package:frontend/pages/explorerPage.dart';
import 'package:frontend/pages/homePage.dart';
import 'package:frontend/pages/libraryPage.dart';
import 'package:frontend/pages/loginPage.dart';
import 'package:frontend/pages/profile.dart';
import 'package:frontend/pages/registerPage.dart';
import 'package:frontend/pages/writerPage.dart';
import 'package:frontend/pages/articleDetailPage.dart';
import 'package:frontend/pages/splashPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/SplashPage",

      routes: {
        "/SplashPage": (context) => const SplashPage(),
        "/LoginPage": (context) => const LoginPage(),
        "/RegisterPage":(context) => const RegisterPage(),

        "/HomePage": (context) => HomePage(),
        "/ExplorerPage": (context) => ExplorerPage(),
        "/WriterPage": (context) => WriterPage(),
        "/ArticlesPage": (context) => ArtcilesPage(),
        "/LibraryPage": (context) => LibraryPage(),
        
        "/ProfilePage": (context) => const ProfilePage(),

        "/ArticlesDetailPage": (context) => ArticleDetailPage(
          post:
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>,
        ),
      },
    );
  }
}
