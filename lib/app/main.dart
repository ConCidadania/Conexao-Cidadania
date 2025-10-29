//---packages--------------------------------------------------------------------
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:con_cidadania/firebase_options.dart';

//---DDD Structure Imports-------------------------------------------------------
// Domain
import 'package:con_cidadania/modules/users/domain/services/auth_service.dart';
import 'package:con_cidadania/modules/users/domain/repositories/user_repository.dart';

// Infrastructure
import 'package:con_cidadania/modules/users/infrastructure/services/firebase_auth_service.dart';
import 'package:con_cidadania/modules/users/infrastructure/repositories/firebase_user_repository.dart';

// Application
import 'package:con_cidadania/modules/users/application/use_cases/register_user.dart';
import 'package:con_cidadania/modules/users/application/use_cases/login_user.dart';
import 'package:con_cidadania/modules/users/application/use_cases/logout_user.dart';
import 'package:con_cidadania/modules/users/application/use_cases/reset_password.dart';
import 'package:con_cidadania/modules/users/application/use_cases/edit_user.dart';
import 'package:con_cidadania/modules/users/application/use_cases/get_current_user.dart';
import 'package:con_cidadania/modules/users/application/use_cases/fetch_all_users.dart';
import 'package:con_cidadania/modules/users/application/services/message_service.dart';
import 'package:con_cidadania/modules/users/application/services/navigation_service.dart';
import 'package:con_cidadania/modules/users/application/state/user_state_notifier.dart';

// Presentation
import 'package:con_cidadania/modules/users/presentation/views/login_view.dart';
import 'package:con_cidadania/modules/users/presentation/views/recover_password_view.dart';
import 'package:con_cidadania/modules/users/presentation/views/register_auth_info_view.dart';
import 'package:con_cidadania/modules/users/presentation/views/register_personal_info1_view.dart';
import 'package:con_cidadania/modules/users/presentation/views/register_personal_info2_view.dart';
import 'package:con_cidadania/modules/users/presentation/views/register_address_info_view.dart';
import 'package:con_cidadania/modules/users/presentation/views/manage_users_view.dart';

// Legacy views (temporary)
import 'package:con_cidadania/old/view/styled_home_view.dart';
import 'package:con_cidadania/old/view/styled_manage_lawsuit_view.dart';

final g = GetIt.instance;

// Global keys for navigation and messaging
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Setup dependency injection for DDD structure
  _setupDependencyInjection();

  runApp(DevicePreview(enabled: false, builder: (context) => const MainApp()));
}

void _setupDependencyInjection() {
  // Infrastructure layer
  g.registerSingleton<AuthService>(FirebaseAuthService());
  g.registerSingleton<UserRepository>(FirebaseUserRepository());

  // Application layer - Use Cases
  g.registerSingleton<RegisterUser>(RegisterUser(
    g<AuthService>(),
    g<UserRepository>(),
  ));
  g.registerSingleton<LoginUser>(LoginUser(
    g<AuthService>(),
    g<UserRepository>(),
  ));
  g.registerSingleton<LogoutUser>(LogoutUser(g<AuthService>()));
  g.registerSingleton<ResetPassword>(ResetPassword(g<AuthService>()));
  g.registerSingleton<EditUser>(EditUser(g<UserRepository>()));
  g.registerSingleton<GetCurrentUser>(GetCurrentUser(
    g<AuthService>(),
    g<UserRepository>(),
  ));
  g.registerSingleton<FetchAllUsers>(FetchAllUsers(g<UserRepository>()));

  // Application layer - Services
  g.registerSingleton<MessageService>(SnackBarMessageService(
    scaffoldMessengerKey: scaffoldMessengerKey,
  ));
  g.registerSingleton<NavigationService>(GlobalKeyNavigationService(
    navigatorKey: navigatorKey,
  ));

  // Application layer - State Management
  g.registerSingleton<UserStateNotifier>(UserStateNotifier(
    registerUser: g<RegisterUser>(),
    loginUser: g<LoginUser>(),
    logoutUser: g<LogoutUser>(),
    resetPassword: g<ResetPassword>(),
    editUser: g<EditUser>(),
    getCurrentUser: g<GetCurrentUser>(),
    fetchAllUsers: g<FetchAllUsers>(),
    messageService: g<MessageService>(),
    navigationService: g<NavigationService>(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserStateNotifier>(
          create: (_) => g<UserStateNotifier>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
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
      ),
    );
  }
}
