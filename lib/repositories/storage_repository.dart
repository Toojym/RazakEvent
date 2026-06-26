import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String> uploadEventImage(Uint8List bytes, String fileExtension, {required bool isPoster}) async {
    final folder = isPoster ? 'posters' : 'headers';
    final fileName = '${_uuid.v4()}.$fileExtension';
    final ref = _storage.ref().child('events/$folder/$fileName');
    
    final metadata = SettableMetadata(contentType: 'image/$fileExtension');
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
