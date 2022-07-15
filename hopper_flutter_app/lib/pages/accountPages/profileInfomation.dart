import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hopper_flutter_app/pages/accountPages/listitem.dart';

class profileInfomation extends StatefulWidget {
  const profileInfomation({Key? key}) : super(key: key);

  @override
  State<profileInfomation> createState() => _profileInfomationState();
}

class _profileInfomationState extends State<profileInfomation> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    TextEditingController firstNameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();
    TextEditingController emailController = TextEditingController();

    Future<Map<String, dynamic>?> getData() async {
      var query = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid.toString())
          .get();

      return query.data();
    }

    return FutureBuilder(
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              var data = snapshot.data as Map<String, dynamic>;

              firstNameController.text = data['firstName'];
              lastNameController.text = data['lastName'];
              emailController.text =
                  FirebaseAuth.instance.currentUser!.email.toString();

              return Scaffold(
                  appBar: AppBar(
                    title: Text("Profile infomation",
                        style: themeData.textTheme.headlineMedium),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.grey,
                    shadowColor: Colors.transparent,
                  ),
                  body: SafeArea(
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      radius: 50,
                                      child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Icon(Icons.person,
                                                size: 80,
                                                color: Colors.grey.shade100),
                                            Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                top: 0,
                                                child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.black12,
                                                    child: IconButton(
                                                        onPressed: () {
                                                          print('click');
                                                        },
                                                        icon: const Icon(
                                                            Icons
                                                                .camera_alt_outlined,
                                                            size: 30,
                                                            color:
                                                                Colors.white))))
                                          ])),
                                ),
                                Row(children: [
                                  Flexible(
                                      child: TextField(
                                          controller: firstNameController,
                                          decoration: const InputDecoration(
                                              icon: Icon(Icons.person),
                                              labelText: "First name"))),
                                  const SizedBox(width: 20),
                                  Flexible(
                                      child: TextField(
                                          controller: lastNameController,
                                          decoration: const InputDecoration(
                                              labelText: "Last name")))
                                ]),
                                Flexible(
                                    child: TextField(
                                        controller: emailController,
                                        decoration: const InputDecoration(
                                            icon: Icon(Icons.email),
                                            labelText: "Email"))),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Spacer(),
                                    OutlinedButton(
                                        onPressed: () {},
                                        child: const Text("Save"))
                                  ],
                                )
                              ]))));
            }
            if (snapshot.hasError) {
              if (snapshot.hasError) {
                return Scaffold(
                    body: Center(child: Text("Error: ${snapshot.error}")));
              }
            }
          }
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }),
        future: getData());

    return Scaffold(
        appBar: AppBar(
          title: Text("Profile infomation",
              style: themeData.textTheme.headlineMedium),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.grey,
          shadowColor: Colors.transparent,
        ),
        body: SafeArea(
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: const [
                        Flexible(
                            child: TextField(
                                decoration: InputDecoration(
                                    icon: Icon(Icons.person),
                                    labelText: "First name"))),
                        SizedBox(width: 20),
                        Flexible(
                            child: TextField(
                                decoration:
                                    InputDecoration(labelText: "Last name")))
                      ])
                    ]))));
  }
}
