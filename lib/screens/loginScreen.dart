import 'package:appwrite/appwrite.dart';
import 'package:flutter_svg/svg.dart';
import 'package:habit_pro/data/Data.dart';
import 'package:habit_pro/screens/signupScreen.dart';
import 'package:provider/provider.dart';
import '../appwrite/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/widgets/alertDialog.dart';
import 'homeScreen.dart';

class LoginScreen extends StatefulWidget {
  bool loading = false;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String name="";
  String email="";
  String password="";
  String dropdownvalue = 'Gender';

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

  signInWithProvider(String provider) {
    try {
      setState(() {
        widget.loading = true;
      });
      context.read<AuthAPI>().signInWithProvider(provider: provider).then((value) {
        if(value[0]!=null){
          FirebaseFirestore.instance.collection("user+"+value[0]).get().then((response) {
            if(response.size>0){
              setState(() {
                widget.loading = false;
              });
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomeScreen()));
            }else{
              saveUserInitialData({"Name":value[1],"Gender":"Male"}, value[0]);
            }
          }).catchError((e){
            setState(() {
              widget.loading = false;
            });
          });
        }else{
          showAlert(title: "Error", text: value[1], actions: true, context: context);
          setState(() {
            widget.loading = false;
          });
        }
      });
    } on AppwriteException catch (e) {
      showAlert(title: 'Login failed', text: e.message.toString(), actions: true, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {

    final AuthAPI appwrite = context.read<AuthAPI>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
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
                      const Text('Login',style: TextStyle(color: Colors.white,fontSize: 24),textAlign: TextAlign.center),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => signInWithProvider('google'),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white),
                            child:
                            SvgPicture.asset('assets/google_icon.svg', width: 20),
                          ),
                          ElevatedButton(
                            onPressed: () => signInWithProvider('github'),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white),
                            child:
                            SvgPicture.asset('assets/github_icon.svg', width: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
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
                      SizedBox(height: 10),
                      TextField(
                        obscureText: true,
                        onChanged: (String s) {
                          password = s;
                        },
                        style: TextStyle(color: Colors.white),
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
                      SizedBox(height: 20),
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
                                child: Text('Login!',
                                    style: TextStyle(color: Colors.black)),
                              )),
                          onPressed: () async {
                            setState(() {
                              widget.loading = true;
                            });
                            appwrite.createEmailSession(email: email, password: password)
                            .then((response) {
                              setState(() {
                                widget.loading = false;
                              });
                              if(response[0]!=null){
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()));
                              }else{
                                showAlert(title: "Error:", text: response[1], actions: true,context: context);
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Opacity(
                        opacity: (widget.loading) ? 1 : 0,
                        child: const Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(child: const Text('New here? Sign up now.',style: TextStyle(color: Colors.white,fontSize: 12),textAlign: TextAlign.center),
                      onTap: (){
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupScreen()));
                      },)

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}