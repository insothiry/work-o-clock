import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:work_o_clock/src/controller/notification_controller.dart';
import 'package:work_o_clock/src/screens/splash_screen/splash_screen.dart';
import 'package:work_o_clock/src/services/socket_service.dart';
import 'package:work_o_clock/src/utils/base_colors.dart';
import 'package:work_o_clock/src/widgets/notification_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pref = await SharedPreferences.getInstance();
  final token = pref.getString('token') ?? '';
  final role = pref.getString('role') ?? '';

  // ⬇️ Register controller before socket init
  final notificationController = Get.put(NotificationController());

  if (token.isNotEmpty) {
    final socketService = SocketService();
    await socketService.initNotificationSocket(token);

    if (role == 'admin') {
      socketService.listenForAdminNotifications((data) {
        notificationController.addNotification(data['message']);
        showBannerNotification(data['message']);
      });
    } else {
      socketService.listenForUserNotifications((data) {
        notificationController.addNotification(data['message']);
        showBannerNotification(data['message']);
      });
    }
  }

  try {
    await Supabase.initialize(
      url: 'https://qhuxhgonomdcirqxrqul.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFodXhoZ29ub21kY2lycXhycXVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMTUzNDYsImV4cCI6MjA2Mjc5MTM0Nn0.qGwj-xpaI0bn0j2WhPFe8nx5r_lTu7DY2Kyf2FIEdso',
    );
    debugPrint('Supabase initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: GetMaterialApp(
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
          cardTheme: CardTheme(
            color: Colors.blue.withOpacity(0.2),
            surfaceTintColor: Colors.transparent,
          ),
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
                  seedColor: BaseColors.primaryColor,
                  surfaceTint: Colors.transparent)
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
          cardTheme: const CardTheme(color: Color.fromARGB(255, 86, 86, 86)),
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
          appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromARGB(255, 57, 56, 56),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
              actionsIconTheme: IconThemeData(color: Colors.white),
              iconTheme: IconThemeData(color: Colors.white)),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              unselectedItemColor: Colors.white),
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: BaseColors.primaryColor)
              .copyWith(background: const Color.fromARGB(255, 57, 56, 56)),
        ),
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
