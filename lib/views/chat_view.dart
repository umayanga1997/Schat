import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypt_chat/constants/app_constants.dart';
import 'package:crypt_chat/utils/services/database.dart';
import 'package:crypt_chat/utils/services/encryption_decryption.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class ChatScreen extends StatefulWidget {
  final String ChatRoomID;

  ChatScreen(this.ChatRoomID);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textEditingController = new TextEditingController();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream<QuerySnapshot> ChatMessageStream;
  DocumentSnapshot partnerDataSnapshot, curentUserDataSnapshot;
  ScrollController controller = ScrollController();

  bool isScAvailable = false;

  @override
  void initState() {
    super.initState();
    init();

    scrollToEnd();
    Currentuser();
  }

  void init() async {
    String partnerID = widget.ChatRoomID.replaceAll("_", "")
        .replaceAll(Constants.currentUser['user_id'], "");
    await databaseMethods.getUserInfoByUserID(partnerID).then((val) {
      partnerDataSnapshot = val;
    });
    await databaseMethods.getChatMessage(widget.ChatRoomID).then((val) {
      ChatMessageStream = val;
    });
    await disableCapture();
  }

  Future<void> disableCapture() async {
    if (partnerDataSnapshot?.data()['isScAvailable'] ?? true) {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      setState(() {
        isScAvailable = true;
      });
    } else {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      setState(() {
        isScAvailable = false;
      });
    }
  }

  Widget chatMessageList() {
    return StreamBuilder(
        stream: ChatMessageStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  controller: controller,
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    String msg = snapshot.data.docs[index].data()["message"];
                    int time = snapshot.data.docs[index].data()["time"];
                    return ChatMessageItem(
                        EncryptionDecryption.decryptMessage(
                            encrypt.Encrypted.fromBase64(msg)),
                        Constants.currentUser['user_id'] ==
                                snapshot.data.docs[index].data()["sentBy"]
                            ? true
                            : false,
                        DateTime.fromMillisecondsSinceEpoch(time));
                  })
              : Container();
        });
  }

  Widget ChatMessageItem(String message, bool isSentByMe, final time) {
    Size screenSize = MediaQuery.of(context).size;

    String messageDate = time.toString().substring(0, 10);
    String messageTimestamp = time.toString().substring(11, 16);
    String currDate = DateTime.fromMillisecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch)
        .toString()
        .substring(0, 10);

    String messageDateFormatted =
        "${messageDate.substring(8, 10)}/${messageDate.substring(5, 7)}/${messageDate.substring(2, 4)}";

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: screenSize.width * 0.6),
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: isSentByMe ? Colors.blue : Color(0xFFF1E6FF),
              borderRadius: isSentByMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    )
                  : BorderRadius.only(
                      topRight: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                      color: isSentByMe ? Colors.white : Colors.black87),
                ),
                Text(
                  messageDate == currDate
                      ? messageTimestamp
                      : messageDateFormatted,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  scrollToEnd() async {
    Timer(Duration(milliseconds: 500),
        () => controller.jumpTo(controller.position.maxScrollExtent));
  }

  void Currentuser() {
    // String cuser = widget.ChatRoomID.replaceAll("_", "")
    //     .replaceAll(partnerDataSnapshot.data()["user_id"], "");
    databaseMethods
        .getUserInfoByUserID(Constants.currentUser['user_id'])
        .then((val) {
      setState(() {
        curentUserDataSnapshot = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    // String username = widget.ChatRoomID.replaceAll("_", "")
    //     .replaceAll(Constants.currentUser['username'], "");
    return partnerDataSnapshot != null
        ? Scaffold(
            appBar: AppBar(
                centerTitle: true,
                elevation: 0,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(partnerDataSnapshot.data()[
                          'picUrl']), //AssetImage("assets/images/user_avatar.png"),
                      maxRadius: 20,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              partnerDataSnapshot
                                      .data()["name"][0]
                                      .toUpperCase() +
                                  partnerDataSnapshot
                                      .data()["name"]
                                      .substring((1)),
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600)),
                          SizedBox(height: 6),
                          Text('@${partnerDataSnapshot.data()['username']}',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.screenshot,
                      color: isScAvailable ? Colors.green : Colors.red,
                    )
                  ],
                )),
            body: Column(
              children: [
                Expanded(child: chatMessageList()),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.05,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.light
                                      ? Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.05)
                                      : Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.4),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: TextField(
                              onTap: () {
                                Timer(
                                    Duration(milliseconds: 300),
                                    () => controller.jumpTo(
                                        controller.position.maxScrollExtent));
                              },
                              controller: textEditingController,
                              decoration: InputDecoration(
                                hintText: "Type message...",
                                hintStyle: TextStyle(
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 15),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Container(
                          width: screenSize.width * 0.125,
                          height: screenSize.width * 0.125,
                          child: FloatingActionButton(
                            onPressed: () {
                              sendMessage();
                            },
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 18,
                            ),
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.9),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        : Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(child: CircularProgressIndicator()),
          );
  }

  sendMessage() {
    if (textEditingController.text.isNotEmpty) {
      String encryptedMessage =
          EncryptionDecryption.encryptMessage(textEditingController.text);
      int time = DateTime.now().millisecondsSinceEpoch;
      Map<String, dynamic> ChatMessageMap = {
        "message": encryptedMessage,
        "sentBy": Constants.currentUser['user_id'],
        "time": time
      };

      databaseMethods.addChatMessage(widget.ChatRoomID, ChatMessageMap);
      databaseMethods.addLastChat(
          widget.ChatRoomID,
          encryptedMessage,
          time,
          Constants.currentUser['user_id'],
          curentUserDataSnapshot.data()['picUrl'],
          partnerDataSnapshot.data()["user_id"],
          // partnerDataSnapshot.data()["name"],
          partnerDataSnapshot.data()['picUrl']);
      textEditingController.text = "";
      scrollToEnd();
    }
  }
}
