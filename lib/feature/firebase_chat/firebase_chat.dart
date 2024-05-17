import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feature/feature/common_print/printlog.dart';
import 'package:firebase_storage/firebase_storage.dart'; 

class FirebaseChat {

// add user to firebase users collection table
  static Future<void> createUser(
      {required String userId,
      required String email,
      required String profileImage,
      required String name,
      required List additionalList}) async {
    try {
      // MessageModel? createUserData = MessageModel(
      //     userId: userId,
      //     email: email,
      //     name: name,
      //     profileImage: profileImage,
      //     // onlineTime: DateTime.now(),
      //     chatList: []);

      // Check if the user exists in the Firebase collection
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId).collection('user')
          .get();

      if (userSnapshot.docs.isEmpty) {
        // User does not exist, so create the user in the Firebase collection
        try {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(userId).collection('user')
              .add(jsonDecode("jsonEncode(createUserData)"));
          Printlog.printLog('User created successfully');
        } catch (e) {
          Printlog.printLog('Failed to create user: $e');
        }
      } else {
        Printlog.printLog('User already exists');
      }

    } catch (e) {
      Printlog.printLog('Error create user : $e');
    }
  }

//update friends list both side
  static Future<String?> updateFriendList(
      {required String senderId, required String receiverId,required String? taskId,String? taskName,String? bidAmount}) async {
  try{
    String? chatId;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .collection('user')
        .get()
        .then((snapshot) {

      for (var doc in snapshot.docs) {
        var chatList = doc.data()['chatList'] as List<dynamic>;
        var alreadyExists = false;

        // Check if the user is already in the friendsList
        for (var friend in chatList) {
          chatId = friend['id'];

          if (friend['id'] == taskId) {
            alreadyExists = true;
            break;
          }
         }    
                              
        // If the user doesn't exist in the friendsList, add them
        if (!alreadyExists) {
          chatList.add({                             
            'userId': receiverId,
            'lastMessage': '',
            'unReadCount':0,
            'timestamp': DateTime.now(),
            'id': taskId,
            'taskName': taskName,
            'bidAmount': bidAmount,
          });
          chatId = taskId;

          // Update the friendsList field in the Firestore document
          doc.reference.update({'chatList': chatList}).then((_) {
            Printlog.printLog('Document updated successfully');
          }).catchError((error) {
            Printlog.printLog('Failed to update document: $error');
          });
        }
      }
    });
                                                                         
    await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('user')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        var chatList = doc.data()['chatList'] as List<dynamic>;
        var alreadyExistsNew = false;
 
        // Check if the user is already in the chatList
        for (var friend in chatList) {
          chatId = friend['id'];
          // if (friend['userId'] == senderId) {
          if (friend['id'] == taskId) {
            alreadyExistsNew = true;
            break;
          }
        } 
                       
                            
        // If the user doesn't exist in the chatList, add them
        if (!alreadyExistsNew) {
          chatList.add({
            'userId': senderId,
            'lastMessage': '',
            'unReadCount':0,
            'timestamp': DateTime.now(),
            'id': taskId,
            'taskName': taskName,
            'bidAmount': bidAmount,
          });
          chatId = taskId;

          // Update the friendsList field in the Firestore document
          doc.reference.update({'chatList': chatList}).then((_) {
            Printlog.printLog('Document updated successfully');
          }).catchError((error) {
            Printlog.printLog('Failed to update document: $error');
          });
        }
      }
    });

    Printlog.printLog('......chatId.....$chatId.....');

    return chatId;

    }catch(e){
      Printlog.printLog('error check on click ....$e');
    }
  return null;
  }


// update read unread status
  static Future<void> updateReadUnread(
      {required String senderId,
      required String chatId,
      required bool isRead}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .collection('user')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        var chatList = doc.data()['chatList'] as List<dynamic>;

        for (var friend in chatList) {
          if (friend['id'] == chatId) {
            friend['isRead'] = isRead;
            friend['unReadCount'] = 0;

            doc.reference.update({'chatList': chatList}).then((_) {
              Printlog.printLog('Document updated successfully');
            }).catchError((error) {
              Printlog.printLog('Failed to update document: $error');
            });
            break; // Exit the loop once the friend is found and updated
          }
        }
      }
    });
  }

// update firebase user profile
  static Future<void> updateFirebaseUserProfile() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc('box.read(BoxStorage.id).toString()')
        .collection('user')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        var profileUpdateData = doc.data();
        profileUpdateData['name'] = '${"box.read(BoxStorage.firstName)"} ${"box.read(BoxStorage.lastName)?.toString()[0].toUpperCase() ?? """}.';
        profileUpdateData['profileImage'] = "box.read(BoxStorage.profileImage)";
        profileUpdateData['email'] = "box.read(BoxStorage.email)";

        doc.reference.update(profileUpdateData).then((_) {
          Printlog.printLog('Document updated successfully');
        }).catchError((error) {
          Printlog.printLog('Failed to update document: $error');
        });
        break;
      }
    });
  }



// image upload function
  static Future<String?> imageUpload({required String pathname})async{
    String? imageUrl;
     try {
            FirebaseStorage storage = FirebaseStorage.instance;
            Reference ref = storage.ref().child(pathname + DateTime.now().toString());
            await ref.putFile(File(pathname));
            imageUrl = await ref.getDownloadURL();
            Printlog.printLog("image path ......... $imageUrl");
                return imageUrl;
              } on FirebaseException catch (e) {
                Printlog.printLog('error catch in image upload ......... $e');
              }
     return imageUrl;
  }


// update status of user when goes to offline or online
  static Future<void> changeOnlineStatus({required bool isOnline})async{
     await FirebaseFirestore.instance
        .collection('users')
        .doc('box.read(BoxStorage.id).toString()')
        .collection('user')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        // var chatList = doc.data()['chatList'] as List<dynamic>;

        // for (var friend in chatList) {
        //   if (friend['id'] == chatId) {
        //     friend['isRead'] = isRead;
        //     friend['unReadCount'] = 0;

            doc.reference.update({'isOnline': isOnline,'timestamp': DateTime.now()}).then((_) {
              Printlog.printLog('Document updated successfully');
            }).catchError((error) {
              Printlog.printLog('Failed to update document: $error');
            });
            break; // Exit the loop once the friend is found and updated
        //   }
        // }
      }
    });
  }


// send message 
// after message send
 void afterMessageSend({required String senderId,required String receiverId,required String chatId,required String lastMessage})async{
        // sendMessageToServer(message: lastMessage,receiverId: receiverId,taskId: chatId);
        await FirebaseFirestore.instance.collection('users').doc(senderId).collection('user').get().then((snapshot) {
        for (var doc in snapshot.docs) {
          var chatList = doc.data()['chatList'] as List<dynamic>;
          
          // Iterate through the chatList to find the friend with matching id
          for (var friend in chatList) {
            if (friend['id'] == chatId) {
            
              // Update the lastMessage field of the friend
              friend['lastMessage'] = lastMessage;
              friend['timestamp'] = DateTime.now();
              friend['isRead'] = true;
              friend['unReadCount']  = 0;
              friend['isByMe'] = true;
      
              // Update the chatList field in the Firestore document
              doc.reference.update({'chatList': chatList}).then((_) {
                Printlog.printLog('Document updated successfully');
              }).catchError((error) {
                Printlog.printLog('Failed to update document: $error');
              });
              break; // Exit the loop once the friend is found and updated
            }
          }
        }   
      });


  await FirebaseFirestore.instance
    .collection('users')
    .doc(receiverId)
    .collection('user')
    .get()
    .then((snapshot) {
  for (var doc in snapshot.docs) {
    var friendsNewList = doc.data()['chatList'] as List<dynamic>;
    
    // Iterate through the chatList to find the friend with matching id
    for (var friend in friendsNewList) {
      if (friend['id'] == chatId) {
        Printlog.printLog('get chat count....${friend['unReadCount']}...${friend['isRead']}');
          if(friend['isRead'] == false){
             friend['unReadCount'] = friend['unReadCount'] + 1;
           }else{
              friend['unReadCount']  = 1;
           }
        // Update the lastMessage field of the friend
        friend['lastMessage'] = lastMessage;
        friend['timestamp'] = DateTime.now();
        friend['isRead'] = false;
        friend['isByMe'] = false;

        
        // Update the chatList field in the Firestore document
        doc.reference.update({'chatList': friendsNewList}).then((_) {
          Printlog.printLog('Document updated successfully');
        }).catchError((error) {
          Printlog.printLog('Failed to update document: $error');
        });
        break; // Exit the loop once the friend is found and updated
      }
    }
  }
});
   
        
}
                                                                                                                                                                      
  // void sendMessage({required String senderId,required String receiverId,required String chatId}) async {
  //   if (textController.text.isNotEmpty || imageFile != null) {
  //     try {
  //     // String lastMessage =  textController.text;
  //     //  File? imageFileLocal = imageFile;
  //     //      onRemoveImage();

  //       if(imageFileLocal != null){
  //         FirebaseChat.imageUpload(pathname: imageFileLocal.path).then((value) async{

  //         await FirebaseFirestore.instance.collection('chat').doc(chatId).collection('messages').add({
  //         'text': lastMessage,
  //         'timestamp': FieldValue.serverTimestamp(),
  //         'senderId': box.read(BoxStorage.id).toString(),
  //         'receiverId': receiverId,
  //         "imagePath":value,
  //       }).then((value) {
  //   loadingWidget(false);
  //         // afterMessageSend(chatId: chatId, senderId: senderId, receiverId: receiverId, lastMessage: lastMessage);
  //       });
  //     });
    
  //    }else{
  //       await FirebaseFirestore.instance.collection('chat').doc(chatId).collection('messages').add({
  //         'text': lastMessage,
  //         'timestamp': FieldValue.serverTimestamp(),
  //         'senderId': box.read(BoxStorage.id).toString(),
  //         'receiverId': receiverId
  //       }).then((value) {
  //   loadingWidget(false);
  //         // afterMessageSend(chatId: chatId, senderId: senderId, receiverId: receiverId, lastMessage: lastMessage);

  //       });
  //       }
  //         afterMessageSend(chatId: chatId, senderId: senderId, receiverId: receiverId, lastMessage:textController.text.isEmpty? "Photo" : lastMessage);



  //     } catch (e) {
  //       Printlog.printLog('Error sending message: $e');
  //   loadingWidget(false);

  //     }
  //   }
  // }     





}