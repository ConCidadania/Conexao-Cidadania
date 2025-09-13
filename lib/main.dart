import 'package:con_cidadania/controller/lawsuit_controller.dart';
import 'package:con_cidadania/controller/user_controller.dart';
import 'package:con_cidadania/view/home_view.dart';
import 'package:con_cidadania/view/login_view.dart';
import 'package:con_cidadania/view/manage_lawsuit_view.dart';
import 'package:con_cidadania/view/manage_users_view.dart';
import 'package:con_cidadania/view/recover_password_view.dart';
import 'package:con_cidadania/view/register_address_info_view.dart';
import 'package:con_cidadania/view/register_auth_info_view.dart';
import 'package:con_cidadania/view/register_personal_info1_view.dart';
import 'package:con_cidadania/view/register_personal_info2_view.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:con_cidadania/firebase_options.dart';

final g = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  g.registerSingleton<UserController>(UserController());
  g.registerSingleton<LawsuitController>(LawsuitController());

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
        'manageLawsuit': (context) => const ManageLawsuitView(),
        'home': (context) => const HomeView(),
      },
    );
  }
}
