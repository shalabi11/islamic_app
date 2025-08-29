// import 'dart:convert';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../../core/services/audio_service.dart';
// import '../../../../core/services/download_service.dart';

// // مودل لتمثيل بيانات الأذان
// class Adhan {
//   final String id;
//   final String name;
//   final String url;
//   final String fajrUrl;
//   Adhan({
//     required this.id,
//     required this.name,
//     required this.url,
//     required this.fajrUrl,
//   });

//   factory Adhan.fromJson(Map<String, dynamic> json) {
//     return Adhan(
//       id: json['id'],
//       name: json['name'],
//       url: json['url'],
//       fajrUrl: json['fajr_url'],
//     );
//   }
// }

// class AdhanSelectionScreen extends StatefulWidget {
//   const AdhanSelectionScreen({super.key});
//   @override
//   State<AdhanSelectionScreen> createState() => _AdhanSelectionScreenState();
// }

// class _AdhanSelectionScreenState extends State<AdhanSelectionScreen> {
//   final AudioService _audioService = AudioService();
//   final DownloadService _downloadService = DownloadService();

//   List<Adhan> _adhans = [];
//   String? _selectedAdhanId;
//   Map<String, bool> _isDownloaded = {};
//   Map<String, double> _downloadProgress = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadAdhans();
//   }

//   Future<void> _loadAdhans() async {
//     final String response = await rootBundle.loadString('assets/adhan.json');
//     final List<dynamic> data = json.decode(response);
//     _adhans = data.map((item) => Adhan.fromJson(item)).toList();

//     final prefs = await SharedPreferences.getInstance();
//     _selectedAdhanId = prefs.getString('selected_adhan_id');

//     for (var adhan in _adhans) {
//       // تحقق من تنزيل كلا الملفين (العادي والفجر)
//       final regularDownloaded = await _downloadService.isFileDownloaded(
//         'adhan',
//         adhan.id,
//       );
//       final fajrDownloaded = await _downloadService.isFileDownloaded(
//         'adhan_fajr',
//         adhan.id,
//       );
//       _isDownloaded[adhan.id] = regularDownloaded && fajrDownloaded;
//     }
//     setState(() {});
//   }

//   Future<void> _selectAdhan(Adhan adhan) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('selected_adhan_id', adhan.id);
//     setState(() {
//       _selectedAdhanId = adhan.id;
//     });
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text("تم اختيار الأذان بنجاح")));
//   }

//   void _startDownload(Adhan adhan) {
//     // البدء بتنزيل كلا الملفين
//     // تنزيل الأذان العادي
//     _downloadService
//         .downloadAudio(adhan.url, 'adhan', adhan.id, (progress) {
//           if (mounted)
//             setState(() {
//               _downloadProgress[adhan.id] = (progress / 2);
//             });
//         })
//         .then((_) {
//           // عند اكتمال الأول، ابدأ بتنزيل الثاني
//           _downloadService
//               .downloadAudio(adhan.fajrUrl, 'adhan_fajr', adhan.id, (progress) {
//                 if (mounted)
//                   setState(() {
//                     _downloadProgress[adhan.id] = 0.5 + (progress / 2);
//                   });
//               })
//               .then((_) {
//                 if (mounted)
//                   setState(() {
//                     _isDownloaded[adhan.id] = true;
//                     _downloadProgress.remove(adhan.id);
//                   });
//               });
//         })
//         .catchError((e) {
//           if (mounted) setState(() => _downloadProgress.remove(adhan.id));
//         });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('اختيار صوت الأذان')),
//       body: _adhans.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: _adhans.length,
//               itemBuilder: (context, index) {
//                 final adhan = _adhans[index];
//                 final isSelected = _selectedAdhanId == adhan.id;
//                 final isDownloading = _downloadProgress.containsKey(adhan.id);
//                 final downloaded = _isDownloaded[adhan.id] ?? false;

//                 return Card(
//                   margin: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   child: ListTile(
//                     title: Text(adhan.name),
//                     leading: IconButton(
//                       icon: const Icon(
//                         Icons.play_circle_outline,
//                         color: Colors.teal,
//                       ),
//                       tooltip: 'استماع لعينة',
//                       onPressed: () => _audioService.play(UrlSource(adhan.url)),
//                     ),
//                     trailing: isDownloading
//                         ? CircularProgressIndicator(
//                             value: _downloadProgress[adhan.id],
//                           )
//                         : downloaded
//                         ? ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: isSelected
//                                   ? Colors.green
//                                   : Colors.grey,
//                               foregroundColor: Colors.white,
//                             ),
//                             onPressed: () => _selectAdhan(adhan),
//                             child: Text(isSelected ? 'تم الاختيار' : 'اختيار'),
//                           )
//                         : IconButton(
//                             icon: const Icon(
//                               Icons.download_for_offline_outlined,
//                             ),
//                             tooltip: 'تنزيل (العادي والفجر)',
//                             onPressed: () => _startDownload(adhan),
//                           ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
