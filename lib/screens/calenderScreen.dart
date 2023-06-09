import 'package:provider/provider.dart';

import '../appwrite/auth_api.dart';
import 'dayTaskScreen.dart';
import 'package:flutter/material.dart';
import '../data/data.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' ;

import 'homeScreen.dart';

class Calendar extends StatefulWidget {
  int index;
  String custName;
  Calendar(this.index, this.custName);
  List<dynamic> completedDays = [];
  dynamic startDate;
  bool loading  = true;
  bool notStarted = true;
  var now = DateTime.now();
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late final AuthAPI appwrite;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            title: (widget.index != -1)
                ? Text(titles.elementAt(widget.index))
                : Text(widget.custName),
            backgroundColor: Colors.red,
          ),
           body: (!widget.loading)?
            Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: SvgPicture.asset(
                                (widget.index != -1)
                                    ? 'assets/${images.elementAt(widget.index)}'
                                    : 'assets/sketch.svg',
                                fit: BoxFit.contain,
                            width: 100,
                            height: 100,),
                          )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Opacity(
                        opacity: (widget.notStarted) ? 1.0 : 0.0,
                        child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                (widget.index != -1)
                                    ? FirebaseFirestore.instance
                                    .collection(
                                    'user+${appwrite.currentUser.$id}')
                                    .doc('IncompleteHabits')
                                    .update({
                                  'Habits': FieldValue.arrayRemove([
                                    titles.elementAt(widget.index) as dynamic
                                  ])
                                }).then((value) {
                                  String date =
                                      '${widget.now.year}-${widget.now.month}-${widget.now.day}';
                                  List<int> numbers = [0];
                                  Map<String, dynamic> startMap = {
                                    'StartDate': date,
                                    'CompletedDays': numbers
                                  };
                                  FirebaseFirestore.instance
                                      .collection(
                                      'user+${appwrite.currentUser.$id}')
                                      .doc(titles.elementAt(widget.index))
                                      .set(startMap)
                                      .then((value) {
                                    setState(() {
                                      widget.notStarted = false;
                                      widget.completedDays.add(0);
                                    });
                                  });
                                })
                                    : FirebaseFirestore.instance
                                    .collection(
                                    'user+${appwrite.currentUser.$id}')
                                    .doc('IncompleteHabits')
                                    .update({
                                  'IncompleteCustomHabits':
                                  FieldValue.arrayRemove(
                                      [widget.custName as dynamic])
                                }).then((value) {
                                  String date =
                                      '${widget.now.year}-${widget.now.month}-${widget.now.day}';
                                  List<int> numbers = [0];
                                  FirebaseFirestore.instance
                                      .collection(
                                      'user+${appwrite.currentUser.$id}')
                                      .doc('CustomHabits')
                                      .collection(widget.custName)
                                      .doc('details')
                                      .update({
                                    'CompletedDays': numbers,
                                    'StartDate': date
                                  }).then((value) {
                                    setState(() {
                                      print('done');
                                      widget.notStarted = false;
                                      widget.completedDays.add(0);
                                    });
                                  });
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red, // Background color
                              ),
                              child: Text(
                                'Start Habit',
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  flex: 3,
                  child: GridView.count(
                    crossAxisCount: 4,
                    children: List.generate(
                      21,
                          (index) => GestureDetector(
                        onTap: () {
                          print(index+1);
                          print(widget.completedDays.contains(index));
                          (widget.notStarted)
                              ? showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Ok',
                                      style:
                                      TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ],
                                title: const Text(
                                    'Please start the habit to view the task'),
                              ))
                              : (index!=0&&!widget.completedDays.contains(index))?
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Ok',
                                      style:
                                      TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ],
                                title: Text(
                                    'Please ensure previous days tasks are done!'),
                              ))
                              :Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => (widget.index != -1)
                                    ? DayTask(
                                    index + 1,
                                    titles.elementAt(widget.index),
                                    widget.completedDays,
                                    false)
                                    : DayTask(index + 1, widget.custName,
                                    widget.completedDays, true),
                              ));
                        },
                        child: Container(
                          margin: EdgeInsets.all(10),
                          child: Card(
                            //
                            color: (widget.completedDays.contains(index+1))?Colors.green:Colors.white,
                            child: Center(
                              child: Text('${index + 1}'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ))
            ],
          ):AlertDialog(content: Column(mainAxisSize: MainAxisSize.min,mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,children: [CircularProgressIndicator(),SizedBox(height: 20,),Text('Loading...')],),),
        ),
        onWillPop: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
          return Future.value(true);
        });
  }

  @override
  void initState() {
    appwrite = context.read<AuthAPI>();
    if (widget.index != -1) {
      FirebaseFirestore.instance
          .collection('user+${appwrite.currentUser.$id}')
          .doc(titles.elementAt(widget.index))
          .snapshots()
          .listen((value) {
        FirebaseFirestore.instance
            .collection('user+${appwrite.currentUser.$id}')
            .doc('IncompleteHabits')
            .get()
            .then((incompleteData) {
          Map<String, dynamic>? habitMap = value.data();
          Map<String, dynamic>? incompleteMap = incompleteData.data();
          List<dynamic> incompleteHabitList = incompleteMap!['Habits'];
          bool status =
          incompleteHabitList.contains(titles.elementAt(widget.index));
          setState(() {
            widget.notStarted = status;
            widget.loading = false;
            if (habitMap != null) {
              widget.completedDays = habitMap['CompletedDays'];
              widget.startDate = habitMap['StartDate'];
            }
            print('done');
          });
        });
      });
    } else {
      FirebaseFirestore.instance
          .collection('user+${appwrite.currentUser.$id}')
          .doc('IncompleteHabits')
          .snapshots()
          .listen((value) {
        FirebaseFirestore.instance
            .collection('user+${appwrite.currentUser.$id}')
            .doc('CustomHabits')
            .collection(widget.custName)
            .doc('details')
            .get()
            .then((value2) {
          List<dynamic> incompleteCustHabits = value.data()!['IncompleteCustomHabits'];
          bool status = incompleteCustHabits.contains(widget.custName);

          setState(() {
            widget.notStarted = status;
            widget.loading = false;
            if (value2.data() != null) {
              widget.startDate = value2.data()!['StartDate'];
              widget.completedDays = value2.data()!['CompletedDays'];
            }
            print(widget.completedDays);
            print(value2.data());
          });
        });
      });
    }
  }
}