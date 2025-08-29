import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/features/prayer_times/views/screens/adhan_selection_screen.dart';
import '../../view_model/prayer_times_cubit.dart';

import '../../view_model/prayer_times_state.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cityController = TextEditingController();
    final countryController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("أوقات الصلاة"),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.settings_voice_outlined),
          //   tooltip: 'اختيار صوت الأذان',
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const AdhanSelectionScreen(),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "البحث حسب المدينة",
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.teal),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: cityController,
                        decoration: const InputDecoration(
                          labelText: 'المدينة',
                          hintText: 'مثال: مكة',
                          prefixIcon: Icon(Icons.location_city),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'الرجاء إدخال اسم المدينة'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: countryController,
                        decoration: const InputDecoration(
                          labelText: 'الدولة',
                          hintText: 'مثال: السعودية',
                          prefixIcon: Icon(Icons.flag),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'الرجاء إدخال اسم الدولة'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context
                                .read<PrayerTimesCubit>()
                                .fetchPrayerTimesByCity(
                                  cityController.text,
                                  countryController.text,
                                );
                          }
                        },
                        child: const Text('بحث'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("أو"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),

            OutlinedButton.icon(
              icon: const Icon(Icons.my_location),
              label: const Text('استخدام موقعي الحالي'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                textStyle: const TextStyle(fontSize: 16, fontFamily: 'Cairo'),
              ),
              onPressed: () {
                context
                    .read<PrayerTimesCubit>()
                    .fetchPrayerTimesByCurrentLocation();
              },
            ),
            const SizedBox(height: 24),

            // --- 3. قسم عرض النتائج ---
            BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
              builder: (context, state) {
                if (state is PrayerTimesLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  );
                } else if (state is PrayerTimesLoaded) {
                  return PrayerTimesResultCard(
                    state: state,
                  ); // استخدام ويدجت منفصلة للنتائج
                } else if (state is PrayerTimesError) {
                  return Text(
                    'حدث خطأ: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  );
                }
                return const SizedBox.shrink(); // لا تعرض شيئاً في الحالة الابتدائية
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ويدجت منفصلة ومحسنة لعرض النتائج
class PrayerTimesResultCard extends StatelessWidget {
  final PrayerTimesLoaded state;

  const PrayerTimesResultCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final locationName = state.locationName;

    final times = state.prayerTimeModel;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ تحقق إذا كان اسم الموقع موجودًا وقم بعرضه
            if (locationName != null)
              Text(
                "أوقات الصلاة لـ",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            if (locationName != null)
              Text(
                locationName,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.teal),
                textAlign: TextAlign.center,
              ),
            const Divider(height: 24),
            PrayerTimeTile(name: "الفجر", time: times.fajr),
            PrayerTimeTile(name: "الشروق", time: times.sunrise),
            PrayerTimeTile(name: "الظهر", time: times.dhuhr),
            PrayerTimeTile(name: "العصر", time: times.asr),
            PrayerTimeTile(name: "المغرب", time: times.maghrib),
            PrayerTimeTile(name: "العشاء", time: times.isha),
          ],
        ),
      ),
    );
  }
}

// ويدجت منفصلة لعرض كل وقت صلاة
class PrayerTimeTile extends StatelessWidget {
  final String name;
  final String time;
  const PrayerTimeTile({super.key, required this.name, required this.time});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        name,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        time,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
