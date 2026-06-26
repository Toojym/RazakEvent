import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Maps file extension to proper MIME content type.
  String _contentTypeForExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/$ext';
    }
  }

  Future<String> uploadEventPoster(Uint8List bytes, String fileExtension) async {
    final fileName = '${_uuid.v4()}.$fileExtension';
    final ref = _storage.ref().child('events/posters/$fileName');

    final metadata = SettableMetadata(contentType: _contentTypeForExtension(fileExtension));
    final uploadTask = await ref.putData(bytes, metadata);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<String> uploadEventPaperwork(Uint8List bytes, String fileName) async {
    final uniqueName = '${_uuid.v4()}_$fileName';
    final ref = _storage.ref().child('events/paperwork/$uniqueName');
    
    final metadata = SettableMetadata(contentType: 'application/pdf');
    final uploadTask = await ref.putData(bytes, metadata);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<String> uploadReportAttachment(Uint8List bytes, String fileName) async {
    final uniqueName = '${_uuid.v4()}_$fileName';
    final ref = _storage.ref().child('reports/$uniqueName');
    
    final uploadTask = await ref.putData(bytes);
    return await uploadTask.ref.getDownloadURL();
  }
}
