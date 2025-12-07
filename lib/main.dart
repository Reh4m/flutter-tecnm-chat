import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/firebase_options.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart' as di;
import 'package:flutter_whatsapp_clon/src/presentation/config/router/index.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/auth/email_verification_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/message_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/contacts_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/direct_chat_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/conversations/group_chat_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/media_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/onboarding_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/auth/phone_authentication_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/theme_provider.dart';
import 'package:flutter_whatsapp_clon/src/presentation/providers/user/user_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es_MX', null);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate();

  await di.init();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => OnboardingProvider(prefs)),
        ChangeNotifierProvider.value(
          value: di.sl<PhoneAuthenticationProvider>(),
        ),
        ChangeNotifierProvider.value(value: di.sl<EmailVerificationProvider>()),
        ChangeNotifierProvider.value(value: di.sl<UserProvider>()),
        ChangeNotifierProvider.value(value: di.sl<ContactsProvider>()),
        ChangeNotifierProvider.value(value: di.sl<DirectChatProvider>()),
        ChangeNotifierProvider.value(value: di.sl<GroupChatProvider>()),
        ChangeNotifierProvider.value(value: di.sl<MessageProvider>()),
        ChangeNotifierProvider.value(value: di.sl<MediaProvider>()),
      ],
      child: const WhatsAppClone(),
    ),
  );
}

class WhatsAppClone extends StatelessWidget {
  const WhatsAppClone({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, themeProvider, __) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Flutter WhatsApp Clone',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.currentThemeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
