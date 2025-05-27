import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/Auth_service.dart';
import 'package:chat_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../models/message.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference? _userCollection;
  CollectionReference? _chatsCollection;
  late AuthService _authService;

  final GetIt _getIt = GetIt.instance;

  DatabaseService() {
    _authService = _getIt.get<AuthService>();

    _setupCollectionReferences();
  }

  void _setupCollectionReferences() {
    _userCollection = _firebaseFirestore
        .collection('users')
        .withConverter<UserProfile>(
          fromFirestore:
              (snapshot, _) => UserProfile.fromJson(snapshot.data()!),
          toFirestore: (UserProfile, _) => UserProfile.toJson(),
        );
    _chatsCollection = _firebaseFirestore
        .collection("chats")
        .withConverter<Chat>(
          fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
          toFirestore: (chat, _) => chat.toJson(),
        );
  }

  Future<void> createUserProfile({required UserProfile user_profile}) async {
    await _userCollection?.doc(user_profile.uid).set(user_profile);
  }

  Stream<QuerySnapshot<UserProfile>> get getUserProfiles {
    return _userCollection
            ?.where("uid", isNotEqualTo: _authService.user!.uid)
            .snapshots()
        as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExists(String uid1, String uid2) async {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
    final result = await _chatsCollection?.doc(chatId).get();
    if (result != null) {
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String uid1, String uid2) {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatId);
    final chat = Chat(id: chatId, participants: [uid1, uid2], messages: []);
    return docRef.set(chat);
  }

  Future<void> sendchatMessage(
    String uid1,
    String uid2,
    Message message,
  ) async {
    final chatId = generateChatId(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatId);
    await docRef.update({
      "messages": FieldValue.arrayUnion([message.toJson()]),
    });
  }

  Stream<DocumentSnapshot<Chat>> getChat(String uid1 , String uid2) {
    String chatId = generateChatId(uid1: uid1, uid2: uid2);
  return _chatsCollection!.doc(chatId).snapshots() as Stream<DocumentSnapshot<Chat>>;
}
}
