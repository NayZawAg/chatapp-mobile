import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_frontend/constants.dart';
import 'package:flutter_frontend/progression.dart';
import 'package:flutter_frontend/model/SessionStore.dart';
import 'package:flutter_frontend/const/minio_to_ip.dart';
import 'package:flutter_frontend/componnets/customlogout.dart';
import 'package:flutter_frontend/services/userservice/api_controller_service.dart';
import 'package:flutter_frontend/services/directMessage/provider/direct_message_provider.dart';
import 'package:flutter_frontend/services/userservice/usermanagement/user_management_service.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({Key? key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  late UserManagementService userManagementService;

  @override
  void initState() {
    super.initState();
    userManagementService = UserManagementService(Dio());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<DirectMessageProvider>(context, listen: false).getAllUsers();
    });
  }

  Future<String?> getToken() async {
    return await AuthController().getToken();
  }

  @override
  Widget build(BuildContext context) {
    // int userLength = SessionStore.sessionData!.mUsers!.length.toInt();
    int? userId;
    bool isAdmins = true;
    bool isClose = true;
    if (SessionStore.sessionData!.currentUser!.memberStatus == false) {
      return CustomLogOut();
    } else {
      return Scaffold(
        backgroundColor: kPriamrybackground,
        appBar: AppBar(
          backgroundColor: navColor,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title: const Text("User Management",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: Consumer<DirectMessageProvider>(
          builder: (context, value, child) {
            if (value.isLoading) {
              return const ProgressionBar(
                imageName: 'aboydatasending.json',
                height: 200,
                size: 200,
              );
            } else if (value.userManagement == null ||
                value.userManagement!.mUsers == null ||
                value.userManagement!.mUsers!.isEmpty) {
              return const ProgressionBar(
                imageName: 'nodatahasFounded.json',
                height: 200,
                size: 200,
              );
            } else {
              int userLength = value.userManagement!.mUsers!.length;

              return ListView.builder(
                itemCount: userLength,
                itemBuilder: (context, index) {
                  int userIds =
                      value.userManagement!.mUsers![index].id!.toInt();

                  bool? isAdmin = value.userManagement!.mUsers![index].admin;
                  bool? isMemberStatus =
                      value.userManagement!.mUsers![index].memberStatus;
                  String userName =
                      value.userManagement!.mUsers![index].name.toString();
                  String email =
                      value.userManagement!.mUsers![index].email.toString();
                  String? profileImage =
                      value.userManagement!.mUsers![index].imageUrl;

                  if (profileImage != null && !kIsWeb) {
                    profileImage = MinioToIP.replaceMinioWithIP(
                        profileImage, ipAddressForMinio);
                  }

                  return ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Stack(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[300],
                              ),
                              child: Center(
                                child: profileImage == null ||
                                        profileImage.isEmpty
                                    ? const Icon(Icons.person)
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          profileImage,
                                          fit: BoxFit.cover,
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                              ),
                            )
                          ],
                        ),
                      ),
                      title: Text(
                        userName,
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        email,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      trailing: SessionStore.sessionData!.currentUser!.admin ==
                                  isAdmins &&
                              !isAdmin!
                          ? Switch(
                              value: isMemberStatus ?? false,
                              onChanged: (value) async {
                                setState(() {
                                  userId = userIds;
                                });
                                var token = await getToken();
                                await userManagementService
                                    .deactivateUser(userId!, token!)
                                    .then((_) {
                                  // After API call completes, reload the data
                                  Provider.of<DirectMessageProvider>(context,
                                          listen: false)
                                      .getAllUsers();
                                  setState(() {
                                    isClose = false;
                                  });
                                });
                              },
                            )
                          : null);
                },
              );
            }
          },
        ),
      );
    }
  }
}
