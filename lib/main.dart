import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_form_data_provider.dart';
import 'screens/splash_screen.dart';
import 'modules/login/login_provider.dart';
import 'modules/onboarding/signup/signup_provider.dart';
import 'modules/dashboard/notifications/notification_screen.dart';
import 'modules/services/services_screen.dart';
import 'modules/services/physical_security/providers/physical_security_provider.dart';
import 'modules/services/physical_security/physical_security_result_screen.dart';
import 'modules/services/physical_security/desired_services_screen.dart';
import 'modules/services/secured_mobility/providers/secured_mobility_provider.dart';
import 'modules/services/outsourcing_talent/providers/outsourcing_talent_provider.dart';
import 'modules/services/digital_security/provider/digital_security_provider.dart';
import 'modules/services/physical_security/physical_security_screen.dart';
import 'modules/onboarding/continue_registration/continue_registration_screen.dart';
import 'modules/settings/wallet/provider/wallet_provider.dart';
import 'modules/services/secured_mobility/desired_services/desired_services_screen.dart';
import 'modules/services/secured_mobility/secured_mobility_screen.dart';
import 'modules/services/secured_mobility/service_configuration_screen.dart';
import 'modules/services/secured_mobility/schedule_service_screen.dart';
import "modules/services/secured_mobility/confirm_order_screen.dart";
import 'modules/services/secured_mobility/payment_screen.dart';
import 'modules/services/secured_mobility/payment_success_screen.dart';
import 'modules/services/outsourcing_talent/desired_services/desired_services_screen.dart';
import 'modules/services/outsourcing_talent/outsourcing_talent_screen.dart';
import 'modules/services/outsourcing_talent/description_of_need_screen.dart';
import 'modules/services/outsourcing_talent/confirmation_screen.dart';
import 'modules/settings/settings_routes.dart';
import 'modules/settings/settings_screen.dart';
import 'modules/settings/profile/provider/profile_provider.dart';
import 'security_profile/providers/security_profile_provider.dart';
import 'modules/settings/provider/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/service_provider.dart';

import 'services/quick_actions_service.dart';

// Import the ProfilePage and SettingsPage
import 'modules/profile/profile_page.dart';
import 'modules/settings/settings_page.dart';

// Create a global navigator key to use in our app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserFormDataProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
        ChangeNotifierProvider(create: (_) => PhysicalSecurityProvider()),
        ChangeNotifierProvider(create: (_) => SecuredMobilityProvider()),
        ChangeNotifierProvider(create: (_) => OutsourcingTalentProvider()),
        ChangeNotifierProvider(create: (_) => DigitalSecurityProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProfileProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        
      ],
      child: const HalogenApp(),
    ),
  );
}

class HalogenApp extends StatefulWidget {
  const HalogenApp({super.key});

  @override
  State<HalogenApp> createState() => _HalogenAppState();
}

class _HalogenAppState extends State<HalogenApp> {
  late QuickActionsService _quickActionsService;
  
  @override
  void initState() {
    super.initState();
    _quickActionsService = QuickActionsService(navigatorKey: navigatorKey);
    _quickActionsService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      navigatorKey: navigatorKey, // Add the navigator key
      title: "Halogen",
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Objective',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: Colors.white,
          hourMinuteTextColor: Colors.black,
          dayPeriodTextColor: Colors.black,
          dayPeriodShape:
              RoundedRectangleBorder(), // Optional for rounded button
          dayPeriodColor: WidgetStateColor.resolveWith(
            (states) =>
                states.contains(WidgetState.selected)
                    ? const Color(0xFFFFCC29)
                    : Colors.white,
          ),
          // Default background when not selected
          dialHandColor: Colors.black,
          dialBackgroundColor: Color(0xFFEDEDED),
          hourMinuteColor: Color(0xFFEDEDED),
          entryModeIconColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          headerForegroundColor: Colors.black,

          // 🔘 Today styling (black circle)
          todayBackgroundColor: WidgetStatePropertyAll(Colors.black),
          todayForegroundColor: WidgetStatePropertyAll(Colors.white),

          // ✅ Selected day styling (brand yellow circle with black text)
          dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFFFCC29); // brand yellow
            }
            return null; // fallback to default
          }),
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.black;
            }
            return Colors.black;
          }),

          dayOverlayColor: WidgetStatePropertyAll(Colors.transparent),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black, // Cancel/OK buttons
            textStyle: const TextStyle(fontFamily: 'Objective'),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          labelStyle: TextStyle(color: Colors.black),
          suffixIconColor: Colors.black,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionColor: Colors.black26,
          selectionHandleColor: Colors.black,
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: const BorderSide(color: Colors.black, width: 1.5),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.black;
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(Colors.white),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF1C2B66);
            }
            return const Color(0xFF1C2B66);
          }),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontFamily: 'Objective'),
          ),
        ),
      ),
      
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/services': (context) => const ServicesScreen(),
        '/physical-security': (context) => const PhysicalSecurityScreen(),
        '/desired-services': (_) => const DesiredServicesScreen(),
        '/result': (_) => const PhysicalSecurityResultScreen(),
        '/continue-registration':
            (context) => const ContinueRegistrationScreen(),
        '/secured-mobility': (context) => const SecuredMobilityScreen(),
        '/secured-mobility/desired-services':
            (context) => const SecuredMobilityDesiredServicesScreen(),
        '/secured-mobility/service-configuration':
            (context) => const SecuredMobilityServiceConfigurationScreen(),
        '/secured-mobility/schedule-service':
            (context) => const ScheduleServiceScreen(),
        '/secured-mobility/summary': (context) => const ConfirmOrderScreen(),
        '/secured-mobility/payment': (context) => const PaymentScreen(),
        '/secured-mobility/payment-success':
            (context) => const PaymentSuccessScreen(),
        '/outsourcing-talent/desired-services':
            (context) => const OutsourcingDesiredServicesScreen(),
        '/outsourcing-talent': (context) => const OutsourcingTalentScreen(),
        '/outsourcing-talent/description':
            (context) => const DescriptionOfNeedScreen(),
        '/outsourcing-talent/confirmation':
            (context) => const ConfirmationScreen(),
        ...settingsRoutes,
        '/settings': (context) => const SettingsScreen(),
        // Add routes for quick actions
        '/profile-page': (context) => ProfilePage(),
        '/sos': (context) => SettingsPage(),
      },
    );
  }
}
