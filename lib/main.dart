import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/AuthRepository.dart';
import 'package:provider/provider.dart';
import 'package:hello_me/Suggestions.dart';
import 'package:english_words/english_words.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

Set<WordPair> savedG = new Set<WordPair>();

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthRepository.instance(),
      child: Consumer(
        builder: (context, AuthRepository user, _) {
          return MaterialApp(
            title: 'Startup Name Generator',
            theme: ThemeData(
              primaryColor: Colors.red,
            ),
            home: RandomWords(),
          );
        },
      ),
    );
  }
}


