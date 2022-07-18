import 'package:firebase_storage/firebase_storage.dart';

class StorageRepository {
  StorageRepository._internal();
  static final _storageRepository = StorageRepository._internal();
  factory StorageRepository.instance() => _storageRepository;

  final Reference _reference = FirebaseStorage.instance.ref();

  Future<String> getDownloadUrl(String child) {
    return _reference.child(child).getDownloadURL();
  }
}
