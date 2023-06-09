import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habit_pro/openai/api.dart' as api;
import 'package:habit_pro/screens/profileScreen.dart';
import 'package:provider/provider.dart';

import '../appwrite/auth_api.dart';
import '../data/data.dart';
import '../utils/widgets/alertDialog.dart';
import 'NewHabitCreationScreen.dart';
import 'calenderScreen.dart';

class HomeScreen extends StatefulWidget {
  String name = "";
  late String userId;
  dynamic gender;
  List<String> custom = [];
  List<dynamic> allCustomHabits = [];
  List<dynamic> allIncompleteHabits = [];

  bool loadingCusCreation = false;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final AuthAPI appwrite;

  @override
  void initState() {
    appwrite = context.read<AuthAPI>();
    FirebaseFirestore.instance
        .collection('user+${appwrite.currentUser.$id}')
        .doc('Id')
        .get()
        .then((value) {
      Map<String, dynamic>? idMap = value.data();
      setState(() {
        widget.gender = idMap!['Gender'];
        widget.name = idMap!['Name'];
      });
      FirebaseFirestore.instance
          .collection('user+${appwrite.currentUser.$id}')
          .doc('IncompleteHabits')
          .get()
          .then((value2) {
        Map<String, dynamic>? incompleteMap = value2.data();
        setState(() {
          widget.allIncompleteHabits = incompleteMap!['Habits'];
          if (idMap!['Allcustomhabits'] != null) {
            widget.allCustomHabits = idMap!['Allcustomhabits'];
          }
        });
      });
    });
    super.initState();
  }

  Future<List<String>> generateHabitData(
      String habitName, String desc, String gender) async {
    return api.generateHabitData(habitName, desc, gender).then((response) {
      if (response != null) {
        final jsonRes = jsonDecode(response.body);
        final choiceRes = jsonRes['choices'][0];
        final messageRes = choiceRes['message']['content'];
        List<String> list = messageRes.split("\n");
        return list;
      } else {
        return [];
      }
    });
  }



  void _onItemSelected(int _newIndex) {
    String habitName = "";
    String habitDesc = "";
    if (_newIndex == 0) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text("New Custom Habit"),
                backgroundColor: Colors.white,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (String m) {
                        habitName = m;
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                          hintText: 'Enter Habit Name',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          hintStyle: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      onChanged: (String m) {
                        habitDesc = m;
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                          hintText: 'Enter Habit Description',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          hintStyle: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "NOTE: Enter a one line small description of your habit for better generation of daily tasks.",
                      style: TextStyle(fontSize: 10, color: Colors.red),
                    )
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (widget.loadingCusCreation == true) {
                        return;
                      }
                      setState(() {
                        widget.loadingCusCreation = true;
                        widget.custom.add(habitName);
                        widget.allCustomHabits.add(habitName);
                      });
                      Map<String, dynamic> idMap = {
                        'Name': widget.name,
                        'Gender': widget.gender,
                        'Allcustomhabits': widget.allCustomHabits
                      };
                      Map<String, dynamic> customMap = {
                        'Habits': widget.allIncompleteHabits,
                        'IncompleteCustomHabits': widget.custom
                      };
                      Navigator.pop(context);
                      showAlert(
                          title: "Loading...",
                          text: "Creating custom tasks using AI. Please wait",
                          actions: false, context: context);
                      generateHabitData(habitName, habitDesc, widget.gender)
                          .then((value) {
                            List<String> finalList = [];
                            for(String i in value){
                              if(i.startsWith("Day")){
                                finalList.add(i);
                                print(i);
                              }
                            }
                        if (finalList.length == 21) {
                          for (int i = 1; i <= 21; i++) {
                            startMap['Task $i'] = finalList[i - 1];
                          }
                          FirebaseFirestore.instance
                              .collection('user+${appwrite.currentUser.$id}')
                              .doc('IncompleteHabits')
                              .set(customMap)
                              .then((value) {
                            FirebaseFirestore.instance
                                .collection('user+${appwrite.currentUser.$id}')
                                .doc('CustomHabits')
                                .collection(habitName)
                                .doc('details')
                                .set(startMap)
                                .then((value) {
                              FirebaseFirestore.instance
                                  .collection(
                                      'user+${appwrite.currentUser.$id}')
                                  .doc('Id')
                                  .set(idMap)
                                  .then((value) {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Calendar(-1, habitName)));
                              });
                            });
                          });
                        } else {
                          Navigator.pop(context);
                          showAlert(
                              title: "Error",
                              text:
                                  "Some error occurred in creating of custom task.",
                              actions: true, context: context);
                        }
                      });
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ));
      setState(() {
        _selectedIndex = _newIndex;
      });
    } else if (_newIndex == 1) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Profile(
                  widget.name, widget.gender, widget.allIncompleteHabits)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          SystemNavigator.pop();
          return Future.value(true);
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              ClipPath(
                clipper: MyClipper(),
                child: Container(
                  color: Colors.red,
                  height: 300,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: (widget.name != null)
                                    ? Text(
                                        'Hey there ${widget.name}!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 20),
                                      )
                                    : CircularProgressIndicator(
                                        backgroundColor: Colors.black,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: (widget.gender == 'Male')
                              ? SvgPicture.asset(
                                  'assets/person.svg',
                                  fit: BoxFit.contain,
                                )
                              : (widget.gender == 'Female')
                                  ? SvgPicture.asset(
                                      'assets/woman.svg',
                                      fit: BoxFit.contain,
                                    )
                                  : Container(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  margin: EdgeInsets.only(top: 200),
                  child: GridView.count(
                      crossAxisCount: 2,
                      children: List.generate(
                          6 + widget.allCustomHabits.length,
                          (index) => GestureDetector(
                                onTap: () {
                                  (index < 6)
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Calendar(index, '')))
                                      : showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                                backgroundColor: Colors.white,
                                                content: const Text(
                                                  'Please select where you want to go',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => Calendar(
                                                                  -1,
                                                                  widget
                                                                      .allCustomHabits
                                                                      .elementAt(
                                                                          index -
                                                                              6))));
                                                    },
                                                    child: const Text(
                                                      'View Task',
                                                      style: TextStyle(
                                                          color: Colors.blue),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  CreateHabit(widget
                                                                      .allCustomHabits
                                                                      .elementAt(
                                                                          index -
                                                                              6))));
                                                    },
                                                    child: Text(
                                                      'Edit custom habit',
                                                      style: TextStyle(
                                                          color: Colors.blue),
                                                    ),
                                                  ),
                                                ],
                                              ));
                                },
                                child: Opacity(
                                  opacity: 0.9,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    child: Card(
                                        color: Colors.white,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: SvgPicture.asset(
                                                  (index < 6)
                                                      ? 'assets/${images.elementAt(index)}'
                                                      : 'assets/sketch.svg',
                                                  width: 70,
                                                  height: 70,
                                                  fit: BoxFit.contain),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(2),
                                              child: Text(
                                                (index < 6)
                                                    ? titles.elementAt(index)
                                                    : widget.allCustomHabits
                                                        .elementAt(index - 6),
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        )),
                                  ),
                                ),
                              ))),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            unselectedItemColor: Colors.black,
            selectedItemColor: Colors.red,
            backgroundColor: Color(0xFF3e3636),
            currentIndex: _selectedIndex,
            onTap: _onItemSelected,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Add',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
