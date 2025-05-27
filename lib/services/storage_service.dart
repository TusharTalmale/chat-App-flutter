import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  StorageService() {}
  Future<String?> uploadUserPfp({
    required File file,
    required String uid,
  }) async {
    Reference fileref = _firebaseStorage
        .ref('users/pfps')
        .child('$uid${p.extension(file.path)}');
    UploadTask Task = fileref.putFile(file);
    return Task.then((p) {
      if (p.state == TaskState.success) {
        return fileref.getDownloadURL();
      }
    });
  }
   Future<String?> uploadImageToChat({
    required File file,
    required String chatId,
  }) async {
    Reference fileref = _firebaseStorage
        .ref('users/$chatId')
        .child('${DateTime.now().toIso8601String()}${p.extension(file.path)}');
    UploadTask Task = fileref.putFile(file);
    return Task.then((p) {
      if (p.state == TaskState.success) {
        return fileref.getDownloadURL();
      }
    });
  }


}
