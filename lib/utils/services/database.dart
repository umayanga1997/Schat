import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  getAllUsers() async {
    return await FirebaseFirestore.instance.collection('users').get();
  }

  dynamic getUserInfoByUserID(var userID) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .get();
  }

  getUserInfoByUserName(String username) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where("username", isEqualTo: username)
        .get();
  }

  updateUserInfo(
      var userID, String name, String bio, bool isScAvailable) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .update({'name': name, 'bio': bio, 'isScAvailable': isScAvailable});
  }

  updateUserProfilePic(var userID, String url) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .update({'picUrl': url});
  }

  getUserInfoByID(var userID) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .get();
  }

  uploadUserInfo(var userID, Map<String, String> userInfoMap) {
    FirebaseFirestore.instance.collection('users').doc(userID).set(userInfoMap);
  }

  createChatRoom(String ChatRoomID, Map<String, dynamic> ChatRoomMap) {
    FirebaseFirestore.instance
        .collection('ChatRooms')
        .doc(ChatRoomID)
        .set(ChatRoomMap);
  }

  addChatMessage(String ChatRoomID, Map<String, dynamic> ChatMessageMap) {
    FirebaseFirestore.instance
        .collection('ChatRooms')
        .doc(ChatRoomID)
        .collection('chats')
        .add(ChatMessageMap);
  }

  addLastChat(String ChatRoomID, String lastChatMessage, int time, String cuser,
      String upic, String nuser, /* String nUsername,*/ String npic) {
    FirebaseFirestore.instance.collection('ChatRooms').doc(ChatRoomID).update({
      'LastChat.Message': lastChatMessage,
      // 'LastChat.pName': nUsername,
      'LastChat.Time': time,
      'LastChat.picUrl' + cuser: upic,
      'LastChat.picUrl' + nuser: npic
    });
  }

  getChatMessage(String ChatRoomID) async {
    return await FirebaseFirestore.instance
        .collection('ChatRooms')
        .doc(ChatRoomID)
        .collection('chats')
        .orderBy("time", descending: false)
        .snapshots();
  }

  getChatRooms(var userId) async {
    return await FirebaseFirestore.instance
        .collection('ChatRooms')
        .where('users', arrayContains: userId)
        .snapshots();
  }

  getCurrUserChatRooms(String ChatRoomID) async {
    return await FirebaseFirestore.instance
        .collection('ChatRooms')
        .where('chatRoomID', isEqualTo: ChatRoomID)
        .snapshots();
  }

  getCurrUserChatRoomsGet(String ChatRoomID) async {
    return await FirebaseFirestore.instance
        .collection('ChatRooms')
        .where('chatRoomID', isEqualTo: ChatRoomID)
        .get();
  }
}
