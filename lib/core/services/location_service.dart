// import 'dart:nativewrappers/_internal/vm/lib/developer.dart';

import 'dart:developer';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
// 1. استيراد الحزمة الجديدة

// الكلاس المساعد يبقى كما هو
class LocationData {
  final Position position;
  final String timezone;
  final String placeName;
  LocationData(this.position, this.timezone, this.placeName);
}

class LocationService {
  Future<LocationData> getCurrentLocationData() async {
    // الكود الخاص بالتحقق من الأذونات والموقع يبقى كما هو
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled. Please enable the services';
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 2. الحصول على المنطقة الزمنية باستخدام الحزمة الجديدة (أبسط بكثير)
    final String timezone = await FlutterTimezone.getLocalTimezone();
    String placeName = "موقع غير معروف"; // قيمة افتراضية
    try {
      // اطلب من الحزمة تحويل الإحداثيات إلى قائمة من العناوين
      // نطلب منه استخدام اللغة العربية "ar"
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        // localeIdentifier: "ar",
      );

      // احصل على أول نتيجة (عادةً ما تكون الأدق)
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        // قم بدمج اسم المدينة والدولة
        placeName = "${place.locality}, ${place.country}";
      }
    } catch (e) {
      log("Error getting place name: $e");
      log("Error getting place name from coordinates: $e");
      // في حال فشل العملية، ستبقى القيمة الافتراضية
    }

    return LocationData(position, timezone, placeName);
  }
}
