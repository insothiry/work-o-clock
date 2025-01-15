import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_o_clock/src/screens/splash_screen/splash_screen.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "WORKO'CLOCK",
      theme: ThemeData(
        cardColor: Colors.white,
        dialogBackgroundColor: Colors.white,
        fontFamily: 'Jost',
        textTheme: const TextTheme(
          bodySmall: TextStyle(fontSize: 14),
          bodyMedium: TextStyle(fontSize: 16),
          headlineLarge: TextStyle(fontSize: 24),
        ),
        tabBarTheme: const TabBarTheme(
          labelStyle: TextStyle(fontSize: 20, fontFamily: 'Jost'),
          unselectedLabelStyle: TextStyle(fontSize: 18, fontFamily: 'Jost'),
        ),
        cardTheme: CardTheme(color: Colors.blue.withOpacity(0.3)),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: BaseColors.secondaryColor)
            .copyWith(background: Colors.white),
      ),
      darkTheme: ThemeData(
        dialogBackgroundColor: Colors.grey[900],
        fontFamily: 'Jost',
        textTheme: const TextTheme(
          bodySmall: TextStyle(fontSize: 14, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.white),
          headlineLarge: TextStyle(fontSize: 24, color: Colors.white),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: Colors.white,
          textColor: Colors.white,
        ),
        cardTheme: const CardTheme(color: Colors.grey),
        dropdownMenuTheme: const DropdownMenuThemeData(
          textStyle: TextStyle(color: Colors.white),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
        tabBarTheme: const TabBarTheme(
            labelStyle: TextStyle(fontSize: 20, fontFamily: 'Jost'),
            unselectedLabelStyle: TextStyle(fontSize: 18, fontFamily: 'Jost'),
            indicatorColor: Colors.blue,
            unselectedLabelColor: Colors.white,
            labelColor: Colors.blue),
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[900],
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
            actionsIconTheme: const IconThemeData(color: Colors.white),
            iconTheme: const IconThemeData(color: Colors.white)),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            unselectedItemColor: Colors.white),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: BaseColors.secondaryColor)
            .copyWith(background: Colors.grey[900]),
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
