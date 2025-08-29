import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/download_service.dart';
import '../../data/models/audio_model.dart';
import '../../data/models/surah_model.dart';

class AudioPlayerWidget extends StatefulWidget {
  final Surah surah;
  const AudioPlayerWidget({super.key, required this.surah});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioService _audioService = AudioService();
  final DownloadService _downloadService = DownloadService();
  PlayerState _playerState = PlayerState.stopped;
  late Audio _selectedReciter;

  Map<int, bool> _isDownloaded = {};
  Map<int, double> _downloadProgress = {};
  Map<int, String> _fileSizes = {}; // لحفظ أحجام الملفات
  bool _isLoadingDownloads = true;

  @override
  void initState() {
    super.initState();
    _selectedReciter = widget.surah.audio.isNotEmpty
        ? widget.surah.audio[0]
        : Audio(
            id: 0,
            reciterAr: 'غير متوفر',
            link: '',
            reciterEn: '',
            rewayaAr: '',
            rewayaEn: '',
            server: '',
          );
    _checkDownloadsAndGetSizes();

    _audioService.onPlayerStateChanged.listen((state) {
      if (mounted)
        setState(() {
          _playerState = state;
        });
    });
  }

  Future<void> _checkDownloadsAndGetSizes() async {
    for (var reciter in widget.surah.audio) {
      final downloaded = await _downloadService.isFileDownloaded(
        widget.surah.number.toString(),
        reciter.id.toString(),
      );
      _isDownloaded[reciter.id] = downloaded;
      // إذا لم يتم تنزيل الملف، احصل على حجمه
      if (!downloaded) {
        final size = await _downloadService.getAudioFileSize(reciter.link);
        if (mounted)
          setState(() {
            _fileSizes[reciter.id] = size;
          });
      }
    }
    if (mounted)
      setState(() {
        _isLoadingDownloads = false;
      });
  }

  void _startDownload(Audio reciter) {
    setState(() {
      _downloadProgress[reciter.id] = 0.0;
    });
    _downloadService
        .downloadAudio(
          reciter.link,
          widget.surah.number.toString(),
          reciter.id.toString(),
          (progress) {
            if (mounted)
              setState(() {
                _downloadProgress[reciter.id] = progress;
              });
          },
        )
        .then((_) {
          if (mounted) {
            setState(() {
              _isDownloaded[reciter.id] = true;
              _downloadProgress.remove(reciter.id);
            });
          }
        })
        .catchError((e) {
          if (mounted) {
            setState(() {
              _downloadProgress.remove(reciter.id);
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        });
  }

  void _cancelDownload(Audio reciter) {
    _downloadService.cancelDownload(
      widget.surah.number.toString(),
      reciter.id.toString(),
    );
    setState(() {
      _downloadProgress.remove(reciter.id);
    });
  }

  Future<void> _playAudio() async {
    final localPath = await _downloadService.getLocalFilePath(
      widget.surah.number.toString(),
      _selectedReciter.id.toString(),
    );

    // هذا الكود الآن سيعمل بشكل صحيح
    if (localPath != null) {
      // إذا كان الملف موجوداً محلياً، مرر DeviceFileSource
      await _audioService.play(DeviceFileSource(localPath));
    } else {
      // إذا لم يكن موجوداً، مرر UrlSource
      await _audioService.play(UrlSource(_selectedReciter.link));
    }
  }

  void _showReciterSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (modalContext, scrollController) {
            return StatefulBuilder(
              builder: (modalContext, modalSetState) {
                return ListView.builder(
                  controller: scrollController,
                  itemCount: widget.surah.audio.length,
                  itemBuilder: (listCtx, index) {
                    final reciter = widget.surah.audio[index];
                    final isSelected = _selectedReciter.id == reciter.id;
                    final isDownloading = _downloadProgress.containsKey(
                      reciter.id,
                    );
                    final downloaded = _isDownloaded[reciter.id] ?? false;
                    final fileSize = _fileSizes[reciter.id] ?? '';

                    return ListTile(
                      title: Text(reciter.reciterAr),
                      subtitle: Text(reciter.rewayaAr),
                      leading: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.teal,
                              size: 28,
                            )
                          : const Icon(Icons.person_outline, size: 28),
                      // --- ✅ عرض حالة التنزيل بشكل تفاعلي ---
                      trailing: isDownloading
                          ? Row(
                              // عرض مؤشر التقدم مع زر الإلغاء
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  value: _downloadProgress[reciter.id],
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _cancelDownload(reciter),
                                ),
                              ],
                            )
                          : downloaded
                          ? const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                              size: 28,
                            )
                          : Row(
                              // عرض زر التنزيل مع حجم الملف
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (fileSize.isNotEmpty)
                                  Text(
                                    fileSize,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.download_for_offline_outlined,
                                  ),
                                  onPressed: () => _startDownload(reciter),
                                ),
                              ],
                            ),
                      onTap: () {
                        setState(() {
                          _selectedReciter = reciter;
                        });
                        _audioService.stop();
                        Navigator.of(ctx).pop();
                      },
                      selected: isSelected,
                      selectedTileColor: Colors.teal.withOpacity(0.1),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioUrl = _selectedReciter.link;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // عرض اسم القارئ المختار
          Text(
            _selectedReciter.reciterAr,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // --- ✅ 4. زر جديد لاختيار القارئ ---
              IconButton(
                icon: const Icon(Icons.person_search, color: Colors.grey),
                onPressed: () => _showReciterSelection(context),
                tooltip: 'اختيار القارئ',
              ),
              // زر التشغيل
              IconButton(
                iconSize: 40,
                icon: Icon(
                  _playerState == PlayerState.playing
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.teal,
                ),
                onPressed: () {
                  if (_selectedReciter.link.isEmpty) return;
                  if (_playerState == PlayerState.playing) {
                    _audioService.pause();
                  } else {
                    _playAudio(); // ✅ استدعاء الدالة الجديدة
                  }
                },
              ),
              // زر الإيقاف
              IconButton(
                iconSize: 40,
                icon: const Icon(
                  Icons.stop_circle_outlined,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  _audioService.stop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
