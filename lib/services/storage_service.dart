import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  StorageService(this._storage);
  final FirebaseStorage _storage;

  Future<String> uploadReportPhoto({
    required String uid,
    required XFile photo,
  }) async {
    final ref = _storage.ref(
        'report_photos/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(
        File(photo.path), SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<void> deletePhotoByUrl(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {

    }
  }
}