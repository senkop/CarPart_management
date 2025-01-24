import 'package:elshaf3y_store/auth.dart';
import 'package:elshaf3y_store/features/seller_feature/data/repositories/driver_repo.dart';
import 'package:elshaf3y_store/features/seller_feature/data/repositories/monthly_record_repo.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/repositories/personal_repo.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/DeleteDriverUseCase.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/GetDriversUseCase.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/UpdateDriverUseCase.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/addDriver_usecase.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/add_personal.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/clear_monthly_records.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/delete_personal.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/get_monthly_rocords_usecase.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/get_personal.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/monthly_record_usecase.dart';
import 'package:elshaf3y_store/features/seller_feature/domain/use_cases/update_personal.dart';
import 'package:elshaf3y_store/presentation/cubit/driver_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/monthly_records_cubit.dart';
import 'package:elshaf3y_store/presentation/cubit/personal_cubit.dart';
import 'package:elshaf3y_store/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elshaf3y_store/data/repositories/seller_repository.dart';
import 'package:elshaf3y_store/domain/use_cases/update_car_part_use_case.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/cubit/seller_cubit.dart';
import 'presentation/cubit/language_cubit.dart';
import 'domain/use_cases/get_sellers_use_case.dart';
import 'domain/use_cases/add_seller_use_case.dart';
import 'domain/use_cases/add_car_part_use_case.dart';
import 'domain/use_cases/delete_seller_use_case.dart';
import 'domain/use_cases/get_transaction_history_use_case.dart';
import 'domain/use_cases/delete_car_part_use_case.dart';
import 'domain/use_cases/update_seller_use_case.dart';

import 'presentation/screens/seller_screen.dart';
import 'presentation/screens/driver_screen.dart';
import 'presentation/screens/personal_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  final sellerRepository = SellerRepository();
  final driverRepository = DriverRepository();
  final personalSpendRepository = PersonalSpendRepository();
  final monthlyRecordRepository = MonthlyGainsRepository();
  final getSellersUseCase = GetSellersUseCase(sellerRepository);
  final addSellerUseCase = AddSellerUseCase(sellerRepository);
  final addCarPartUseCase = AddCarPartUseCase(sellerRepository);
  final updateCarPartUseCase = UpdateCarPartUseCase(sellerRepository);
  final deleteSellerUseCase = DeleteSellerUseCase(sellerRepository);
  final getTransactionHistoryUseCase = GetTransactionHistoryUseCase(sellerRepository);
  final deleteCarPartUseCase = DeleteCarPartUseCase(sellerRepository);
  final updateSellerUseCase = UpdateSellerUseCase(sellerRepository);
  final getDriversUseCase = GetDriversUseCase(driverRepository);
  final addDriverUseCase = AddDriverUseCase(driverRepository);
  final updateDriverUseCase = UpdateDriverUseCase(driverRepository);
  final deleteDriverUseCase = DeleteDriverUseCase(driverRepository);
  final getPersonalSpendsUseCase = GetPersonalSpendsUseCase(personalSpendRepository);
  final addPersonalSpendUseCase = AddPersonalSpendUseCase(personalSpendRepository);
  final updatePersonalSpendUseCase = UpdatePersonalSpendUseCase(personalSpendRepository);
  final deletePersonalSpendUseCase = DeletePersonalSpendUseCase(personalSpendRepository);
  final getMonthlyRecordsUseCase = GetMonthlyRecordsUseCase(monthlyRecordRepository);
  final addMonthlyRecordUseCase = AddMonthlyRecordUseCase(monthlyRecordRepository);
  final clearMonthlyRecordsUseCase = ClearMonthlyRecordsUseCase(monthlyRecordRepository);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MyApp(
        getSellersUseCase: getSellersUseCase,
        addSellerUseCase: addSellerUseCase,
        addCarPartUseCase: addCarPartUseCase,
        updateCarPartUseCase: updateCarPartUseCase,
        deleteSellerUseCase: deleteSellerUseCase,
        getTransactionHistoryUseCase: getTransactionHistoryUseCase,
        deleteCarPartUseCase: deleteCarPartUseCase,
        updateSellerUseCase: updateSellerUseCase,
        getDriversUseCase: getDriversUseCase,
        addDriverUseCase: addDriverUseCase,
        updateDriverUseCase: updateDriverUseCase,
        deleteDriverUseCase: deleteDriverUseCase,
        getPersonalSpendsUseCase: getPersonalSpendsUseCase,
        addPersonalSpendUseCase: addPersonalSpendUseCase,
        updatePersonalSpendUseCase: updatePersonalSpendUseCase,
        deletePersonalSpendUseCase: deletePersonalSpendUseCase,
        getMonthlyRecordsUseCase: getMonthlyRecordsUseCase,
        addMonthlyRecordUseCase: addMonthlyRecordUseCase,
        clearMonthlyRecordsUseCase: clearMonthlyRecordsUseCase,
        sharedPreferences: sharedPreferences,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GetSellersUseCase getSellersUseCase;
  final AddSellerUseCase addSellerUseCase;
  final AddCarPartUseCase addCarPartUseCase;
  final UpdateCarPartUseCase updateCarPartUseCase;
  final DeleteSellerUseCase deleteSellerUseCase;
  final GetTransactionHistoryUseCase getTransactionHistoryUseCase;
  final DeleteCarPartUseCase deleteCarPartUseCase;
  final UpdateSellerUseCase updateSellerUseCase;
  final GetDriversUseCase getDriversUseCase;
  final AddDriverUseCase addDriverUseCase;
  final UpdateDriverUseCase updateDriverUseCase;
  final DeleteDriverUseCase deleteDriverUseCase;
  final GetPersonalSpendsUseCase getPersonalSpendsUseCase;
  final AddPersonalSpendUseCase addPersonalSpendUseCase;
  final UpdatePersonalSpendUseCase updatePersonalSpendUseCase;
  final DeletePersonalSpendUseCase deletePersonalSpendUseCase;
  final GetMonthlyRecordsUseCase getMonthlyRecordsUseCase;
  final AddMonthlyRecordUseCase addMonthlyRecordUseCase;
  final ClearMonthlyRecordsUseCase clearMonthlyRecordsUseCase;
  final SharedPreferences sharedPreferences;

  const MyApp({
    super.key,
    required this.getSellersUseCase,
    required this.addSellerUseCase,
    required this.addCarPartUseCase,
    required this.updateCarPartUseCase,
    required this.deleteSellerUseCase,
    required this.getTransactionHistoryUseCase,
    required this.deleteCarPartUseCase,
    required this.updateSellerUseCase,
    required this.getDriversUseCase,
    required this.addDriverUseCase,
    required this.updateDriverUseCase,
    required this.deleteDriverUseCase,
    required this.getPersonalSpendsUseCase,
    required this.addPersonalSpendUseCase,
    required this.updatePersonalSpendUseCase,
    required this.deletePersonalSpendUseCase,
    required this.getMonthlyRecordsUseCase,
    required this.addMonthlyRecordUseCase,
    required this.clearMonthlyRecordsUseCase,
    required this.sharedPreferences,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SellerCubit(
            getSellersUseCase: getSellersUseCase,
            addSellerUseCase: addSellerUseCase,
            addCarPartUseCase: addCarPartUseCase,
            updateCarPartUseCase: updateCarPartUseCase,
            deleteSellerUseCase: deleteSellerUseCase,
            getTransactionHistoryUseCase: getTransactionHistoryUseCase,
            deleteCarPartUseCase: deleteCarPartUseCase,
            updateSellerUseCase: updateSellerUseCase,
          ),
        ),
        BlocProvider(
          create: (_) => DriverCubit(
            getDriversUseCase: getDriversUseCase,
            addDriverUseCase: addDriverUseCase,
            updateDriverUseCase: updateDriverUseCase,
            deleteDriverUseCase: deleteDriverUseCase,
          ),
        ),
        BlocProvider(
          create: (_) => PersonalSpendCubit(
            getPersonalSpendsUseCase: getPersonalSpendsUseCase,
            addPersonalSpendUseCase: addPersonalSpendUseCase,
            updatePersonalSpendUseCase: updatePersonalSpendUseCase,
            deletePersonalSpendUseCase: deletePersonalSpendUseCase,
          ),
        ),
        BlocProvider(
          create: (_) => MonthlyRecordCubit(
            getMonthlyRecordsUseCase: getMonthlyRecordsUseCase,
            addMonthlyRecordUseCase: addMonthlyRecordUseCase,
            clearMonthlyRecordsUseCase: clearMonthlyRecordsUseCase,
          ),
        ),
        BlocProvider(
          create: (_) => LanguageCubit(sharedPreferences),
        ),
      ],
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (context, locale) {
            return ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
         child:   MaterialApp(
            debugShowCheckedModeBanner: false,
            color: Colors.white,
            title: 'Store Management',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: MainScreen(),
            ));
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AuthService _authService = AuthService();  // Firebase Auth service

  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    SellerScreen(),
    DriverScreen(),
    PersonalSpendScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load drivers and personal spends when the app starts
    context.read<SellerCubit>().loadSellers();
    context.read<DriverCubit>().loadDrivers();
    context.read<PersonalSpendCubit>().loadPersonalSpends();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
 
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _authService.getToken(),  // Firebase authentication token check
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          // User is logged in, show the app's main content
          return Scaffold(
            body: IndexedStack(
              index: _selectedIndex,
              children: _widgetOptions,
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: CustomNavItem(
                    icon: Icons.store,
                    label: 'Sellers',
                    isSelected: _selectedIndex == 0,
                    onTap: () => _onItemTapped(0),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: CustomNavItem(
                    icon: Icons.directions_car,
                    label: 'Drivers',
                    isSelected: _selectedIndex == 1,
                    onTap: () => _onItemTapped(1),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: CustomNavItem(
                    icon: Icons.account_balance_wallet,
                    label: 'Personal',
                    isSelected: _selectedIndex == 2,
                    onTap: () => _onItemTapped(2),
                  ),
                  label: '',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.amber[800],
              onTap: _onItemTapped,
            ),
          );
        } else {
          // User is not logged in, show the authentication screen
          return LoginScreen();  // Your login screen
        }
      },
    );
  }
}

class CustomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isSelected ? 64 : 40,
            height: isSelected ? 32 : 40,
            decoration: ShapeDecoration(
              color: isSelected ? const Color(0xFFF2F2F2) : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.black : Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF191C1F)
                  : const Color(0xFF4D4D4D),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}