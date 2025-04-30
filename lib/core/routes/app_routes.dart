import 'package:flutter/material.dart';
import 'package:material_tracking/features/auth/presentation/pages/login_page.dart';
import 'package:material_tracking/features/auth/presentation/pages/splash_page.dart';
import 'package:material_tracking/features/materials/presentation/pages/home_page.dart';
import 'package:material_tracking/features/materials/presentation/pages/add_material_page.dart';
import 'package:material_tracking/features/materials/presentation/pages/material_details_page.dart';
import 'package:material_tracking/features/materials/presentation/pages/consumption_page.dart';
import 'package:material_tracking/features/materials/presentation/pages/consumption_history_page.dart';
import 'package:material_tracking/features/materials/presentation/pages/reports_page.dart';
import 'package:material_tracking/features/auth/presentation/pages/users_page.dart';
import 'package:material_tracking/features/materials/presentation/pages/settings_page.dart';
import 'package:material_tracking/features/materials/presentation/pages/consumption_details_page.dart';
import 'package:material_tracking/features/materials/domain/models/material_model.dart';
import 'package:material_tracking/features/materials/domain/models/consumption_model.dart';

class AppRoutes {
  static String splash = '/';
  static String login = '/login';
  static String home = '/home';
  static String addMaterial = '/add-material';
  static String materialDetails = '/material-details';
  static String consumption = '/consumption';
  static String history = '/history';
  static String reports = '/reports';
  static String users = '/users';
  static String settings = '/settings';
  static String consumptionDetails = '/consumption-details';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/add-material':
        return MaterialPageRoute(builder: (_) => const AddMaterialPage());
      case '/material-details':
        final material = settings.arguments as MaterialModel;
        return MaterialPageRoute(
          builder: (_) => MaterialDetailsPage(material: material),
        );
      case '/consumption':
        return MaterialPageRoute(builder: (_) => const ConsumptionPage());
      case '/history':
        return MaterialPageRoute(
          builder: (_) => const ConsumptionHistoryPage(),
        );
      case '/reports':
        return MaterialPageRoute(builder: (_) => const ReportsPage());
      case '/users':
        return MaterialPageRoute(builder: (_) => const UsersPage());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case '/consumption-details':
        final consumption = settings.arguments as ConsumptionModel;
        return MaterialPageRoute(
          builder: (_) => ConsumptionDetailsPage(consumption: consumption),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
