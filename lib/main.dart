import 'package:account_book/provider/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'routes/routes.dart';
import 'package:provider/provider.dart';
import 'package:account_book/provider/date.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Date()),
          ChangeNotifierProvider(create: (context) => ThemeNotifier()),
        ],
        child: Consumer<ThemeNotifier>(
            builder: (_, themeNotifier, __) => MaterialApp(
                title: '강원 🧡 정윤 가계부',
                // theme: ThemeData.dark(),
                theme: ThemeData(
                    // This is the theme of your application.
                    //
                    // Try running your application with "flutter run". You'll see the
                    // application has a blue toolbar. Then, without quitting the app, try
                    // changing the primarySwatch below to Colors.green and then invoke
                    // "hot reload" (press "r" in the console where you ran "flutter run",
                    // or simply save your changes to "hot reload" in a Flutter IDE).
                    // Notice that the counter didn't reset back to zero; the application
                    // is not restarted.
                    primarySwatch: Colors.purple,
                    primaryColor: Colors.purple,
                    brightness: themeNotifier.darkTheme
                        ? Brightness.dark
                        : Brightness.light,
                    fontFamily: "NanumSquareRound"),
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 0.9),
                    child: child!,
                  );
                },
                initialRoute: '/',
                routes: Routes().getRoutes(context),
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate
                ],
                supportedLocales: const [Locale('ko', 'KR')],
                onGenerateRoute: (RouteSettings settings) {
                  Widget targetPage =
                      Routes().getRoutesWidget()[settings.name]!;

                  return PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        targetPage,
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      var begin = const Offset(1.0, 0);
                      var end = Offset.zero;
                      var curve = Curves.elasticIn;

                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(
                        CurveTween(
                          curve: curve,
                        ),
                      );

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  );
                },
                locale: const Locale('ko'))));
  }
}
