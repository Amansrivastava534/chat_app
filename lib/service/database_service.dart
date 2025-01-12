import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  /// reference for our collection
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  /// saving the userdata
  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid
    });
  }

  ///getting the userdata
   Future gettingUserData(String email) async {
    QuerySnapshot snapshot = await userCollection.where("email",isEqualTo: email).get();
    return snapshot;
   }

   /// get user groups
 getUserGroups() async {
    return userCollection.doc(uid).snapshots();
 }


 /// creating a group

Future createGroup(String userName, String id, String groupName) async{
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName":groupName,
      "groupIcon":"",
      "admin":"${id}_$userName",
      "members": [],
      "groupId":"",
      "recentMessage":"",
      "recentMessageSender":""
    });
    /// update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_${userName}"]),
      "groupId":groupDocumentReference.id,
    });


    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
}

  /// getting the chat
  getChat(String groupId)async{
    return groupCollection.doc(groupId).collection("messages").orderBy("time").snapshots();
  }

  Future getGroupAdmin(String groupId) async{
    DocumentReference documentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    return documentSnapshot['admin'];
  }


  /// get group member
  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

}
