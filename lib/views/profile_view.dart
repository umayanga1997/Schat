import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypt_chat/utils/services/database.dart';
import 'package:crypt_chat/views/chat_view.dart';
import 'package:crypt_chat/views/home_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:crypt_chat/constants/app_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:location/location.dart';
//import 'package:webview_flutter/webview_flutter.dart';
//import 'package:geolocator/geolocator.dart';

class ProfileScreen extends StatefulWidget {

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final scaffoldKey=GlobalKey<ScaffoldState>();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  QuerySnapshot searchUserSnapshot;
  TextEditingController NameEditingController = new TextEditingController();
  TextEditingController BioEditingController = new TextEditingController();
  TextEditingController currentAddress = new TextEditingController();
  bool isNameValid=true;
  bool isBioValid=true;

  File imageFile;
  final picker=ImagePicker();

  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  //LocationData _locationData;

  @override
  Future<void> initState() {
    asyncMethod();
    databaseMethods.getUserInfoByUsername(Constants.currentUser)
        .then((val){
      setState(() {
        searchUserSnapshot=val;
        NameEditingController.text=val.docs[0].data()['name'];
        BioEditingController.text=val.docs[0].data()['bio'];
      });
    });
    super.initState();
  }

  asyncMethod() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    currentAddress.text = (await location.getLocation()) as String;
    print(location.getLocation());
  }

  updateUserInfo(){
    setState(() {
      NameEditingController.text.trim().length < 3 || NameEditingController.text.trim().isEmpty ? isNameValid=false:isNameValid=true;
      BioEditingController.text.trim().length > 30 || BioEditingController.text.trim().isEmpty ?isBioValid=false:isBioValid=true;
    });

    if(isNameValid && isBioValid){
      databaseMethods.updateUserInfo(Constants.currentUser, NameEditingController.text, BioEditingController.text);
      SnackBar snackBar=SnackBar(duration: Duration(seconds: 2),content: Text('Profile updated!'));
      scaffoldKey.currentState.showSnackBar(snackBar);
      FocusScope.of(context).unfocus();
    }
  }

  Future pickImage(ImageSource source) async {
    final temp=await picker.getImage(source: source,maxHeight: 480, maxWidth: 640,imageQuality: 30);
    setState(() {
      imageFile=File(temp.path);
    });
    SnackBar snackBar=SnackBar(content: Text('Profile Picture updated!'));
    scaffoldKey.currentState.showSnackBar(snackBar);
    final url=await uploadImage();
    databaseMethods.updateUserProfilePic(Constants.currentUser, url);
  }

  uploadImage() async {
    final firebaseStorageRef= FirebaseStorage.instance.ref().child(Constants.currentUser+DateTime.now().toString());
    final task=await firebaseStorageRef.putFile(imageFile);
    _goToPage2();
    return task.ref.getDownloadURL();
  }

  Future _goToPage2() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(/*text: 'Profile Picture updated!',*/),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize=MediaQuery.of(context).size;
    if (searchUserSnapshot!=null) {
      return GestureDetector(
      onTap:  () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text('Profile', style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          elevation: 0,
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.05,horizontal: 15),
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(0, 10))
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover, //jkedit
                              //image:AssetImage("assets/images/user_avatar.png"),
                              image: NetworkImage(searchUserSnapshot.docs[0].data()['picUrl']),
                          ),
                      ),

                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: InkWell(
                            onTap: (){
                              showModalBottomSheet(context: context, builder: (builder)=>bottomSheet(screenSize)); //jkedit
                            },
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              Center(
                child: Container(
                  child: Text('@${searchUserSnapshot.docs[0].data()['username']}',style: TextStyle(color:MediaQuery.of(context).platformBrightness==Brightness.light ? Constants.kPrimaryColor:Constants.kSecondaryColor,fontSize: 15,fontWeight: FontWeight.bold),),
                ),
              ),
              SizedBox(
                height: 35,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
                child: Column(
                  children: [
                    ProfileTextField(context,"Name", "Enter name",NameEditingController),
                    ProfileTextField(context,"Bio", "Enter bio",BioEditingController),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1),
                      child: RaisedButton(
                        onPressed: () {
                          updateUserInfo();
                        },
                        color: MediaQuery.of(context).platformBrightness==Brightness.light ? Constants.kPrimaryColor:Constants.kSecondaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "UPDATE",
                          style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 2.2,
                              color: MediaQuery.of(context).platformBrightness==Brightness.light ? Colors.white:Colors.black87),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container( //location jkedit
                padding: const EdgeInsets.all(45.0),
                child: Column(
                  children: [
                    LocationTextField(context, "$lat + $long" ,"", currentAddress),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    } else {
      return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(child: CircularProgressIndicator()),
    );
    }
  }

  Widget bottomSheet(Size screenSize) {
    return Container(
      height: screenSize.height * 0.14,
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children:[
          Text(
            "Choose Profile photo",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children:[
            FlatButton.icon(
              icon: Icon(Icons.camera),
              onPressed: () {
                pickImage(ImageSource.camera);
              },
              label: Text("Camera"),
            ),
            FlatButton.icon(
              icon: Icon(Icons.image),
              onPressed: () {
                pickImage(ImageSource.gallery);
              },
              label: Text("Gallery"),
            ),
          ])
        ],
      ),
    );
  }

  Widget ProfileTextField(BuildContext context,
      String labelText, String placeholder, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        controller: controller ,
        style: TextStyle(fontWeight: FontWeight.bold,),
        decoration: InputDecoration(
            prefixIcon: Icon(
              labelText=='Bio'?Icons.info_outline_rounded:Icons.account_circle_rounded,
              color: MediaQuery.of(context).platformBrightness==Brightness.light ? Constants.kPrimaryColor:Colors.grey,
            ),
            suffixIcon: IconButton(
              onPressed: () {
              },
              icon: Icon(
                Icons.edit,
                color: MediaQuery.of(context).platformBrightness==Brightness.light ? Colors.grey:Constants.kPrimaryColor,
              ),
            ),
            contentPadding: EdgeInsets.only(bottom: 3),
            labelText: labelText,
            labelStyle: TextStyle(
                color: MediaQuery.of(context).platformBrightness==Brightness.light ? Colors.black45:Colors.grey
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            errorText: labelText=='Name'? (isNameValid ? null : "Name too short") : (isBioValid ? null : BioEditingController.text.trim().isEmpty ? "Bio too short":"Bio too long"),
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: MediaQuery.of(context).platformBrightness==Brightness.light ? Colors.black:Colors.white70,
            )),
      ),
    );
  }

  Widget LocationTextField(BuildContext context,
      String labelText, String placeholder, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 1.0),
      child: TextField(
        readOnly: true,
        controller: controller,
        style: TextStyle(fontWeight: FontWeight.bold,),
        decoration: InputDecoration(
            prefixIcon: IconButton(
              icon: Icon(Icons.location_on),
              onPressed: () async {
                await getLoca();
              },

              //labelText=='Current Location'?Icons.my_location:Icons.location_on_rounded,
              color: MediaQuery
                  .of(context)
                  .platformBrightness == Brightness.light ? Constants
                  .kPrimaryColor : Colors.grey,
            ),
            suffixIcon: IconButton(
              onPressed: () {},
              icon: Icon(

                Icons.send,
                color: MediaQuery
                    .of(context)
                    .platformBrightness == Brightness.light
                    ? Colors.grey
                    : Constants.kPrimaryColor,
              ),
            ),
            contentPadding: EdgeInsets.only(bottom: 3),
            labelText: labelText,
            labelStyle: TextStyle(
                color: MediaQuery
                    .of(context)
                    .platformBrightness == Brightness.light
                    ? Colors.black45
                    : Colors.grey
            )),
      ),
    );
  }
   double  lat;
  double long;
  Future<void> getLoca()async{
    final Location lc = Location();
    var gg = await lc.getLocation();
    lat = gg.latitude;
    long = gg.longitude;
    setState(() {

    });
    print(gg.toString());
  }
}



