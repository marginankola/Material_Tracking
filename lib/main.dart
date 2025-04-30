import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_tracking/core/routes/app_routes.dart';
import 'package:material_tracking/core/services/connectivity_service.dart';
import 'package:material_tracking/core/services/firebase_service.dart';
import 'package:material_tracking/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:material_tracking/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:material_tracking/features/auth/presentation/bloc/auth_event.dart';
import 'package:material_tracking/features/auth/presentation/pages/login_page.dart';
import 'package:material_tracking/features/auth/presentation/pages/splash_page.dart';
import 'package:material_tracking/features/materials/data/repositories/firebase_materials_repository.dart';
import 'package:material_tracking/features/materials/data/repositories/local_materials_repository.dart';
import 'package:material_tracking/features/materials/domain/models/material_model.dart';
import 'package:material_tracking/features/materials/domain/models/consumption_model.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_bloc.dart';
import 'package:material_tracking/features/materials/presentation/bloc/materials_event.dart';
import 'package:material_tracking/features/materials/presentation/pages/home_page.dart';
import 'package:material_tracking/features/materials/presentation/pages/add_material_page.dart';
import 'package:material_tracking/features/materials/presentation/pages/material_details_page.dart';
import 'package:material_tracking/features/materials/presentation/pages/consumption_history_page.dart';
import 'package:material_tracking/features/materials/presentation/pages/consumption_details_page.dart';
import 'package:material_tracking/features/materials/presentation/pages/reports_page.dart';
import 'package:material_tracking/features/settings/presentation/pages/settings_page.dart';
import 'package:material_tracking/features/auth/presentation/pages/users_page.dart';
import 'package:material_tracking/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with the configuration
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase services
    final firebaseService = FirebaseService();
    await firebaseService.initialize();

    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MaterialModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ConsumptionModelAdapter());
    }

    // Open boxes with proper types
    await Hive.openBox<Map>('users');
    await Hive.openBox<MaterialModel>('materials');
    await Hive.openBox<ConsumptionModel>('consumptions');
    await Hive.openBox<Map>('products');
  } catch (e) {
    print('Error initializing app: $e');
    // Handle initialization error gracefully
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing app: $e'),
          ),
        ),
      ),
    );
    return;
  }

  runApp(const MaterialTrackingApp());
}

class MaterialTrackingApp extends StatelessWidget {
  const MaterialTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    final connectivityService = ConnectivityService();
    final authRepository = AuthRepositoryImpl();
    final firebaseRepository = FirebaseMaterialsRepository(firebaseService);
    final localRepository = LocalMaterialsRepository(
      materialsBox: Hive.box<MaterialModel>('materials'),
      consumptionsBox: Hive.box<ConsumptionModel>('consumptions'),
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc(repository: authRepository)..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => MaterialsBloc(
            firebaseRepository: firebaseRepository,
            localRepository: localRepository,
            connectivityService: connectivityService,
          )..add(LoadMaterialsEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Material Tracking App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashPage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/users': (context) => const UsersPage(),
          '/settings': (context) => const SettingsPage(),
          '/add-material': (context) => const AddMaterialPage(),
          '/material-details': (context) {
            final material =
                ModalRoute.of(context)!.settings.arguments as MaterialModel;
            return MaterialDetailsPage(material: material);
          },
          '/consumption-history': (context) => const ConsumptionHistoryPage(),
          '/consumption-details': (context) {
            final consumption =
                ModalRoute.of(context)!.settings.arguments as ConsumptionModel;
            return ConsumptionDetailsPage(consumption: consumption);
          },
          '/reports': (context) => const ReportsPage(),
        },
      ),
    );
  }
}
