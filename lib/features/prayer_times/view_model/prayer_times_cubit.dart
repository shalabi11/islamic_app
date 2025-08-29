import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:islamic_app/core/services/location_service.dart';

import '../data/repository/prayer_times_repository.dart';
import 'prayer_times_state.dart';

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  final PrayerTimesRepository _repository;
  final LocationService _locationService;

  PrayerTimesCubit(this._repository, this._locationService)
    : super(PrayerTimesInitial());

  Future<void> fetchPrayerTimesByCity(String city, String country) async {
    try {
      emit(PrayerTimesLoading());
      final prayerTimes = await _repository.getPrayerTimes(city, country);
      emit(PrayerTimesLoaded(prayerTimes, locationName: "$city, $country"));
    } catch (e) {
      emit(PrayerTimesError(e.toString()));
    }
  }

  Future<void> fetchPrayerTimesByCurrentLocation() async {
    try {
      emit(PrayerTimesLoading());
      final locationData = await _locationService.getCurrentLocationData();
      final prayerTimes = await _repository.getPrayerTimesByCoordinates(
        locationData.position.latitude,
        locationData.position.longitude,
        locationData.timezone,
      );
      // ✅ مرر اسم الموقع الذي حصلنا عليه من الخدمة
      emit(
        PrayerTimesLoaded(prayerTimes, locationName: locationData.placeName),
      );
    } catch (e) {
      emit(PrayerTimesError(e.toString()));
    }
  }
}
