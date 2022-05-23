import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypt_chat/constants/app_constants.dart';
import 'package:crypt_chat/utils/helpers/helper_functions.dart';
import 'package:crypt_chat/utils/services/auth.dart';
import 'package:crypt_chat/utils/services/database.dart';
import 'package:crypt_chat/views/chat_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot searchUserSnapshot;
  TextEditingController SearchEditingController = new TextEditingController();

  QuerySnapshot UsersSnapshot;
  QuerySnapshot ChatRoomsSnapshot;

  Widget searchUsersList() {
    return searchUserSnapshot != null
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchUserSnapshot.docs.length,
            itemBuilder: (context, index) {
              return UserItem(
                searchUserSnapshot.docs[index].data()["user_id"] ?? "",
                searchUserSnapshot.docs[index].data()["username"],
                searchUserSnapshot.docs[index].data()["name"],
                searchUserSnapshot.docs[index].data()["bio"],
                searchUserSnapshot.docs[index].data()["picUrl"],
              );
            })
        : Container();
  }

  createChatRoom(String userID) {
    List<String> users = [userID, Constants.currentUser['user_id']];
    String chatRoomID =
        HelperFunctions.getChatRoomId(userID, Constants.currentUser['user_id']);
    Map<String, dynamic> ChatRoomMap = {
      'chatRoomID': chatRoomID,
      'users': users
    };
    databaseMethods.createChatRoom(chatRoomID, ChatRoomMap);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => ChatScreen(chatRoomID)));
  }

  Widget userList() {
    return UsersSnapshot != null
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: UsersSnapshot.docs.length,
            itemBuilder: (context, index) {
              if (UsersSnapshot != null) {
                return UserItem(
                    UsersSnapshot.docs[index].data()["user_id"] ?? "",
                    UsersSnapshot.docs[index].data()["username"],
                    UsersSnapshot.docs[index].data()["name"],
                    UsersSnapshot.docs[index].data()["bio"],
                    UsersSnapshot.docs[index].data()["picUrl"]);
              } else {
                return null;
              }
            })
        : Container();
  }

  Widget UserItem(
      var userID, String username, String name, String bio, String pic) {
    return userID != Constants.currentUser['user_id']
        ? InkWell(
            onTap: () {
              String chatRoomID = HelperFunctions.getChatRoomId(
                  userID, Constants.currentUser['user_id']);
              databaseMethods.getCurrUserChatRoomsGet(chatRoomID).then((val) {
                val.size > 0
                    ? Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatScreen(chatRoomID)))
                    : createChatRoom(userID);
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                              pic), //AssetImage("assets/images/user_avatar.png"),
                          maxRadius: 28,
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                        name[0].toUpperCase() +
                                            name.substring((1)),
                                        style: TextStyle(fontSize: 16)),
                                    Text(' - @${username}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.light
                                                ? Colors.black54
                                                : Colors.white54,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                                SizedBox(height: 6),
                                Text(bio,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600))
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  @override
  void initState() {
    getAllUsers();
    super.initState();
  }

  void getAllUsers() {
    databaseMethods.getAllUsers().then((val) => {
          setState(() {
            UsersSnapshot = val;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return UsersSnapshot != null
        ? Scaffold(
            appBar: AppBar(
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Users',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: screenSize.height * 0.024),
                    ),
                    Text(
                      "${UsersSnapshot.docs.length - 1} users",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: screenSize.height * 0.02),
                    ),
                  ],
                )),
            body: Container(
              child: Column(
                children: [
                  Divider(color: Colors.white70, height: 0.5),
                  Container(
                      child: Row(
                    children: [
                      Expanded(
                          child: Container(
                        height: screenSize.height * 0.06,
                        child: TextField(
                          controller: SearchEditingController,
                          onChanged: (value) {
                            if (value == null || value == '') {
                              searchUserSnapshot = null;
                              getAllUsers();
                            }
                          },
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search username...',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Constants.kPrimaryColor,
                          ),
                        ),
                      )),
                      InkWell(
                        onTap: () {
                          databaseMethods
                              .getUserInfoByUserName(
                                  SearchEditingController.text)
                              .then((val) {
                            setState(() {
                              searchUserSnapshot = val;
                            });
                          });
                        },
                        child: Container(
                            height: screenSize.height * 0.06,
                            width: screenSize.width * 0.125,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                            ),
                            child: Icon(
                              Icons.search,
                              color: Colors.white70,
                            )),
                      ),
                    ],
                  )),
                  Expanded(
                      child: searchUserSnapshot != null
                          ? searchUserSnapshot.docs.length > 0
                              ? searchUsersList()
                              : Text("User Not Found!")
                          : userList())
                ],
              ),
            ),
          )
        : Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(child: CircularProgressIndicator()),
          );
  }
}
