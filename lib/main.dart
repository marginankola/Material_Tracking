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
import 'package:material_tracking/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(MaterialModelAdapter());
  Hive.registerAdapter(ConsumptionModelAdapter());
  await Hive.openBox<MaterialModel>('materials');
  await Hive.openBox<ConsumptionModel>('consumptions');

  // Initialize services
  final firebaseService = FirebaseService();
  await firebaseService.initialize();
  final connectivityService = ConnectivityService();

  // Initialize repositories
  final firebaseRepository = FirebaseMaterialsRepository(firebaseService);
  final localRepository = LocalMaterialsRepository(
    materialsBox: Hive.box<MaterialModel>('materials'),
    consumptionsBox: Hive.box<ConsumptionModel>('consumptions'),
  );
  final authRepository = AuthRepositoryImpl();

  runApp(MaterialTrackingApp(
    firebaseRepository: firebaseRepository,
    localRepository: localRepository,
    connectivityService: connectivityService,
    authRepository: authRepository,
  ));
}

class MaterialTrackingApp extends StatelessWidget {
  final FirebaseMaterialsRepository firebaseRepository;
  final LocalMaterialsRepository localRepository;
  final ConnectivityService connectivityService;
  final AuthRepositoryImpl authRepository;

  const MaterialTrackingApp({
    super.key,
    required this.firebaseRepository,
    required this.localRepository,
    required this.connectivityService,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authRepository: authRepository)
            ..add(AuthCheckRequested()),
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
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
