import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  final Dio _dio = Dio();
  final Map<String, CancelToken> _cancelTokens = {};

  // الدالة الآن تستقبل "نوع" الملف لإنشاء مسار فريد
  Future<String> _getFilePath(String type, String id) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$id-$type.mp3';
  }

  Future<bool> isFileDownloaded(String type, String id) async {
    final filePath = await _getFilePath(type, id);
    return await File(filePath).exists();
  }

  // ✅ دالة جديدة للحصول على حجم الملف من الإنترنت
  Future<String> getAudioFileSize(String url) async {
    try {
      final response = await _dio.head(url);
      final size = response.headers.value('content-length');
      if (size != null) {
        final sizeInBytes = int.parse(size);
        // تحويل الحجم إلى ميغابايت
        final sizeInMb = (sizeInBytes / (1024 * 1024)).toStringAsFixed(1);
        return '$sizeInMb MB';
      }
    } catch (e) {
      // تجاهل الخطأ إذا فشل الحصول على الحجم
    }
    return ''; // أعد قيمة فارغة في حال الفشل
  }

  Future<void> downloadAudio(
    String url,
    String type,
    String id,
    Function(double) onProgress,
  ) async {
    final filePath = await _getFilePath(type, id);
    final cancelToken = CancelToken();
    final downloadKey = '$id-$type';
    _cancelTokens[downloadKey] = cancelToken;

    try {
      await _dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );
    } catch (e) {
      // ✅ --- التعديل هنا ---
      // طباعة الخطأ الحقيقي في الـ Debug Console
      log("Dio download error: $e");

      // إرسال رسالة خطأ أكثر تفصيلاً للمستخدم
      if (e is DioException) {
        throw "فشل التنزيل: ${e.message} , ";
      }
      throw "فشل تنزيل الملف لسبب غير معروف";
      // --- نهاية التعديل ---
    } finally {
      _cancelTokens.remove(downloadKey);
    }
  }

  void cancelDownload(String type, String id) {
    final downloadKey = '$id-$type';
    _cancelTokens[downloadKey]?.cancel();
  }

  Future<String?> getLocalFilePath(String type, String id) async {
    if (await isFileDownloaded(type, id)) {
      return await _getFilePath(type, id);
    }
    return null;
  }
}
