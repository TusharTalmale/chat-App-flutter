import 'package:chat_app/Widgets/chat_tile.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/Auth_service.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AuthService _authService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          IconButton(
            onPressed: _logout,
            color: const Color.fromARGB(231, 255, 122, 82),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _buildUI(),
    );
  }

  Future<void> _logout() async {
    bool result = await _authService.logout();
    if (result) {
      _alertService.showTost(
        text: "Successfully Logged Out",
        icon: Icons.check_box,
      );
      _navigationService.pushReplacementNamed("/login");
    }
  }

  Widget _buildUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 20.0,
      ),
      child: _chatList(),
    );
  }

 
  Widget _chatList() {
    return StreamBuilder<QuerySnapshot<UserProfile>>(
      stream: _databaseService.getUserProfiles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Unable to load data",
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No users found"));
        }

        // Basic list implementation - replace with your _userListItem later
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final user = doc.data();
            return ChatTile(userProfile: user,
             onTap: () async{
               final chatExists = await _databaseService
               .checkChatExists(_authService.user!.uid, user.uid!);
                if(!chatExists){
                  await _databaseService.createNewChat(_authService.user!.uid, user.uid!);
                }
                _navigationService.push(MaterialPageRoute(builder: (context){
                  return ChatPage(recipient: user);
                },),);
                }
                );
           

          },
        );
      },
    );
  }
  }

