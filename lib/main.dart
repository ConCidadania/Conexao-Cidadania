import 'package:app_mobile2/controller/user_controller.dart';
import 'package:app_mobile2/view/home_view.dart';
import 'package:app_mobile2/view/login_view.dart';
import 'package:app_mobile2/view/manage_users_view.dart';
import 'package:app_mobile2/view/recover_password_view.dart';
import 'package:app_mobile2/view/register_address_info_view.dart';
import 'package:app_mobile2/view/register_auth_info_view.dart';
import 'package:app_mobile2/view/register_personal_info1_view.dart';
import 'package:app_mobile2/view/register_personal_info2_view.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_mobile2/firebase_options.dart';

final g = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  g.registerSingleton<UserController>(UserController());

  runApp(DevicePreview(enabled: true, builder: (context) => const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Rotas de Navegação
      initialRoute: 'login',
      routes: {
        'login': (context) => const LoginView(),
        'recover': (context) => const RecoverPasswordView(),
        'registerAuth': (context) => const RegisterAuthInfoView(),
        'registerPersonal1': (context) => const RegisterPersonalInfo1View(),
        'registerPersonal2': (context) => const RegisterPersonalInfo2View(),
        'registerAddress': (context) => const RegisterAddressInfoView(),
        'manageUsers': (context) => const ManageUsersView(),
        'home': (context) => const HomeView(),
      },
    );
  }
}
