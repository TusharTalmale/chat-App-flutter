
import 'dart:io';

import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/Auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:chat_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:path/path.dart' as path; 



class ChatPage extends StatefulWidget {
  final UserProfile recipient;

  const ChatPage({super.key, required this.recipient});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
    ChatUser? currentUser, otherUser;

  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late NavigationService _navigationService;
  late StorageService _storageService;
late MediaService _mediaService ;
  final TextEditingController _messageController = TextEditingController();
  late String _chatId;


  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _navigationService = _getIt.get<NavigationService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    _chatId = generateChatId(
      uid1: _authService.user!.uid,
      uid2: widget.recipient.uid!,
    );
    currentUser =ChatUser(id: _authService.user!.uid!, firstName: _authService.user!.displayName,);
    otherUser = ChatUser(id: widget.recipient.uid! , firstName: widget.recipient.name! , profileImage: widget.recipient.pfpURL);
  }
 
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipient.name!),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _navigationService.goBack(),
        ),
      ),
      body:_buildUI(),
        resizeToAvoidBottomInset: true,
      
    );
  }
  Widget _buildUI(){
    return StreamBuilder(stream: _databaseService.getChat(currentUser!.id,otherUser!.id),
     builder: (context ,snapshot){

      Chat? chat = snapshot.data?.data();
      List<ChatMessage> message = [] ;
      if(chat != null && chat.messages != null){
        message = _generateMessageList(chat.messages!);
      }

      return DashChat(
      messageOptions: MessageOptions(
        showOtherUsersAvatar: true,
        showTime: true,
      ),
      inputOptions: InputOptions(
        alwaysShowSend: true,
        trailing: [
          _mediaMessagebutton(),
        ]
      ),
      
       currentUser: currentUser! ,
       onSend: _sendMessage,
       messages: message,
       );
    });
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
if(chatMessage.medias?.isNotEmpty ?? false){
if(chatMessage.medias!.first.type == MediaType.image){
 Message message =  Message(
    senderID: currentUser!.id,
     content: chatMessage.medias!.first.url , 
     messageType: MessageType.Image,
      sentAt: Timestamp.fromDate(chatMessage.createdAt)
    );
    await _databaseService.sendchatMessage(currentUser!.id,otherUser!.id, message);}
} else{
     Message message =  Message(
    senderID: currentUser!.id,
     content: chatMessage.text , 
     messageType: MessageType.Text,
      sentAt: Timestamp.fromDate(chatMessage.createdAt)
    );
    await _databaseService.sendchatMessage(currentUser!.id,otherUser!.id, message);
}
  }

  List<ChatMessage> _generateMessageList(List<Message> message) {
    List<ChatMessage> chatMessage =message.map((m){
      if(m.messageType == MessageType.Image){
              return ChatMessage(user: m.senderID == currentUser!.id ? currentUser! : otherUser!, createdAt: m.sentAt!.toDate(), medias :[ ChatMedia(url: m.content! , fileName : "",type:MediaType.image)],);

      }
      else{
              return ChatMessage(user: m.senderID == currentUser!.id ? currentUser! : otherUser!, text : m.content! ,createdAt: m.sentAt!.toDate(),);

      }
    }).toList();
    chatMessage.sort((a,b){
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessage;
  }

  Widget _mediaMessagebutton(){
    return IconButton(onPressed: () async{
      File? file = await _mediaService.getImageFromGallary();
      if(file != null ){
        String chatId = generateChatId(uid1: currentUser!.id, uid2: otherUser!.id);
        String? downloadURL = await _storageService.uploadImageToChat(file: file, chatId: chatId);
        if(downloadURL != null ){
        ChatMessage chatMessage = ChatMessage(
          user: currentUser!, 
          createdAt: DateTime.now(),
          medias: [
            ChatMedia(
              url: downloadURL,
               fileName: '',
                type: MediaType.image
                ),
          ]
        );
try {
  await _sendMessage(chatMessage);
} catch (e) {
  print("Send failed: $e");
}
        }     
      }
    }, icon: Icon(
      Icons.image,
      color: Theme.of(context ).colorScheme.primary,
    ));

  }
}
