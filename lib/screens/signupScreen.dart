import 'package:appwrite/appwrite.dart';
import 'package:flutter_svg/svg.dart';
import 'package:habit_pro/data/data.dart';
import 'package:habit_pro/screens/LoginScreen.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/models.dart' as models;
import '../appwrite/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/widgets/alertDialog.dart';
import 'homeScreen.dart';

class SignupScreen extends StatefulWidget {
  bool loading = false;

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late String name;
  late String email;
  late String password;
  String dropdownvalue = 'Gender';

  Future<models.User?> createUser(String email,String password) async {
    try {
      final response = await context.read<AuthAPI>().createUser(email: email,password: password);
      return response[1];
    } on AppwriteException catch (e) {
      showAlert(title: 'Signup failed', text: e.message.toString(),actions: true,context: context);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    saveUserInitialData(Map<String, dynamic> idMap,String uid){
      FirebaseFirestore.instance
          .collection(
          'user+$uid')
          .doc('Id')
          .set(idMap)
          .then((value) {
        FirebaseFirestore.instance
            .collection(
            'user+$uid')
            .doc('IncompleteHabits')
            .set({'Habits': titles}).then((value) {
          setState(() {
            widget.loading = false;
          });
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen()));
        });
      });
    }
    final AuthAPI appwrite = context.read<AuthAPI>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.15),
        child: ListView(
          children: <Widget>[
            SvgPicture.asset('assets/habit_pro_logo.svg', fit: BoxFit.contain),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Text('SignUp',style: TextStyle(color: Colors.white,fontSize: 24),textAlign: TextAlign.center),
                    SizedBox(height: 20),
                    TextField(
                      onChanged: (String s) {
                        name = s;
                      },
                      style: TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                          hintText: 'Name',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          hintStyle: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (String s) {
                        email = s;
                      },
                      style: TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.mail,
                            color: Colors.white,
                          ),
                          hintText: 'Email',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          hintStyle: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      obscureText: true,
                      onChanged: (String s) {
                        password = s;
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.white,
                          ),
                          hintText: 'Password',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          hintStyle: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 20),
                    DropdownButton(
                      dropdownColor: Colors.black,
                      value: dropdownvalue,
                      icon: const Icon(Icons.arrow_downward, color: Colors.white),
                      iconSize: 20,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownvalue = newValue!;
                        });
                      },
                      items: menu,
                    ),
                    const SizedBox(height: 20),
                    Opacity(
                      opacity: (widget.loading) ? 0 : 1,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:  MaterialStateProperty.all(Colors.white),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              )
                          ),

                        ),

                        child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('Signup!',
                                  style: TextStyle(color: Colors.black)),
                            )),
                        onPressed: () async {
                          setState(() {
                            widget.loading = true;
                          });
                          createUser(email, password).then((response) {
                            if(response!=null){
                              Map<String, dynamic> idMap = {
                                'Gender': dropdownvalue,
                                'Name': name
                              };
                              FirebaseFirestore.instance
                                  .collection(
                                  'user+${response.$id}')
                                  .doc('Id')
                                  .set(idMap)
                                  .then((value) {
                                FirebaseFirestore.instance
                                    .collection(
                                    'user+${response.$id}')
                                    .doc('IncompleteHabits')
                                    .set({'Habits': titles}).then((value) {
                                  setState(() {
                                    widget.loading = false;
                                  });
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen()));
                                });
                              });
                            }else{
                              setState(() {
                                widget.loading = false;
                              });
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Opacity(
                      opacity: (widget.loading) ? 0 : 1,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:  MaterialStateProperty.all(Colors.white),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              )
                          ),

                        ),

                        child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('Start Anonymously!',
                                  style: TextStyle(color: Colors.black)),
                            )),
                        onPressed: () async {
                          if(dropdownvalue=="Gender"){
                            showAlert(title: "Select gender", text: "Please select one of the gender options", actions: true, context: context);
                          }else{
                            setState(() {
                              widget.loading = true;
                            });
                            appwrite.createAnonymousSession().then((response) {
                              Map<String, dynamic> idMap = {
                                'Gender': dropdownvalue,
                                'Name': "Anonymous"
                              };
                              saveUserInitialData(idMap, response.userId);
                            });
                          }
                        },
                      ),
                    ),
                    Opacity(
                      opacity: (widget.loading) ? 1 : 0,
                      child: const Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(child: const Text('Go back to login page.',style: TextStyle(color: Colors.white,fontSize: 12),textAlign: TextAlign.center),
                      onTap: (){
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      },)

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}