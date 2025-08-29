import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/app_router.dart';
import 'package:islamic_app/core/services/location_service.dart';
import 'package:islamic_app/core/services/notification_service.dart';
import 'package:islamic_app/features/home/home_Screen.dart';
import 'package:islamic_app/features/prayer_times/views/screens/adhan_screen.dart';
import 'package:islamic_app/features/prayer_times/views/screens/prayer_times_screen.dart';
import 'package:islamic_app/features/quran/data/repository/quran_repository.dart';
import 'package:islamic_app/features/quran/view_model/quran_cubit.dart';
import 'features/prayer_times/data/repository/prayer_times_repository.dart';
import 'features/prayer_times/view_model/prayer_times_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تعديل دالة init لتقبل دالة callback
  await NotificationService().init();
  runApp(const MyApp());
}

// ✅ دالة سيتم استدعاؤها عند الضغط على التنبيه
void onNotificationTapped(String? payload) {
  if (payload != null && AppRouter.navigatorKey.currentState != null) {
    AppRouter.navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (context) => AdhanScreen(prayerName: payload)),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => PrayerTimesRepository()),
        RepositoryProvider(create: (context) => LocationService()),
        RepositoryProvider(create: (context) => QuranRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => PrayerTimesCubit(
              context.read<PrayerTimesRepository>(),
              context.read<LocationService>(),
            ),
          ),
          BlocProvider(
            create: (context) => QuranCubit(
              context.read<QuranRepository>(), // ✅ أضف هذا السطر
            ),
          ),
        ],
        child: MaterialApp(
          navigatorKey: AppRouter.navigatorKey,

          title: 'تطبيق إسلامي',

          debugShowCheckedModeBanner: false,
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          theme: ThemeData(
            primarySwatch: Colors.teal,
            fontFamily: 'Cairo',
            scaffoldBackgroundColor: Colors.grey[100],
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
