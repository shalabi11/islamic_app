import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:islamic_app/core/services/database_services.dart';
import 'package:islamic_app/core/services/dio_serviece.dart';
import 'package:islamic_app/features/prayer_times/data/model/prayer_time_model.dart';

class PrayerTimesRepository {
  final Dio _dio = DioService().dio;
  final DatabaseService _dbService = DatabaseService();

  Future<PrayerTimeModel> getPrayerTimes(String city, String country) async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // ✅ إنشاء مفتاح فريد للمدينة والتاريخ
    final String locationKey =
        '${city.toLowerCase()}-${country.toLowerCase()}-$today';

    PrayerTimeModel? localData = await _dbService.getPrayerTimes(locationKey);
    if (localData != null) {
      print("Fetching prayer times from LOCAL DATABASE for key: $locationKey");
      return localData;
    }

    print("Fetching prayer times from API for key: $locationKey");
    try {
      final response = await _dio.get(
        "http://api.aladhan.com/v1/timingsByCity",
        queryParameters: {'city': city, 'country': country, 'method': 5},
      );
      final timings = response.data['data']['timings'];
      final prayerTimes = PrayerTimeModel.fromJson(timings);

      await _dbService.insertPrayerTimes(locationKey, today, prayerTimes);
      return prayerTimes;
    } on DioException catch (e) {
      throw "Failed to load prayer times. Error: ${e.message}";
    } catch (e) {
      throw "An unexpected error occurred.";
    }
  }

  Future<PrayerTimeModel> getPrayerTimesByCoordinates(
    double latitude,
    double longitude,
    String timezone,
  ) async {
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // ✅ إنشاء مفتاح فريد للإحداثيات والتاريخ
    final String locationKey =
        '${latitude.toStringAsFixed(2)}-${longitude.toStringAsFixed(2)}-$today';

    PrayerTimeModel? localData = await _dbService.getPrayerTimes(locationKey);
    if (localData != null) {
      print("Fetching prayer times from LOCAL DATABASE for key: $locationKey");
      return localData;
    }

    print("Fetching prayer times from API for key: $locationKey");
    try {
      final response = await _dio.get(
        "http://api.aladhan.com/v1/timings",
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': 5,
          'timezonestring': timezone,
        },
      );
      final timings = response.data['data']['timings'];
      final prayerTimes = PrayerTimeModel.fromJson(timings);

      await _dbService.insertPrayerTimes(locationKey, today, prayerTimes);
      return prayerTimes;
    } on DioException catch (e) {
      throw "Failed to load prayer times. Error: ${e.message}";
    } catch (e) {
      throw "An unexpected error occurred.";
    }
  }
}
