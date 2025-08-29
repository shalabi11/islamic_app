import 'package:equatable/equatable.dart';
import 'package:islamic_app/features/prayer_times/data/model/prayer_time_model.dart';

abstract class PrayerTimesState extends Equatable {
  const PrayerTimesState();

  @override
  List<Object> get props => [];
}

class PrayerTimesInitial extends PrayerTimesState {}

class PrayerTimesLoading extends PrayerTimesState {}

class PrayerTimesLoaded extends PrayerTimesState {
  final PrayerTimeModel prayerTimeModel;
  final String? locationName;

  const PrayerTimesLoaded(this.prayerTimeModel, {this.locationName});

  @override
  List<Object> get props => [prayerTimeModel, ?locationName];
}

class PrayerTimesError extends PrayerTimesState {
  final String message;

  const PrayerTimesError(this.message);

  @override
  List<Object> get props => [message];
}
