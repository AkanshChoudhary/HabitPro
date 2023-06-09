import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../appwrite/auth_api.dart';
import 'calenderScreen.dart';
import '../data/data.dart';

class DayTask extends StatefulWidget {
  int index;
  String habitName;
  bool isCustom;
  List<dynamic> completedDays;
  String taskDes = " ";

  DayTask(this.index, this.habitName, this.completedDays, this.isCustom);

  @override
  _DayTaskState createState() => _DayTaskState();
}

class _DayTaskState extends State<DayTask> {
  late final AuthAPI appwrite;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
       Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => (widget.isCustom)?Calendar(-1, widget.habitName):Calendar(titles.indexOf(widget.habitName), widget.habitName)));
       return Future.value(true);
       },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Day ${widget.index}'),
          backgroundColor: Colors.red,
          automaticallyImplyLeading: false,
          leading: GestureDetector(
          child:Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onTap: () {
          Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => (widget.isCustom)?Calendar(-1, widget.habitName):Calendar(titles.indexOf(widget.habitName), widget.habitName)));
          },),),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Center(
                child:
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: (!widget.isCustom)?Text(habitMap['${widget.habitName}']!.elementAt(widget.index-1),textAlign: TextAlign.center,maxLines: 7,style: TextStyle(color: Colors.white,fontSize: 25),):
                  (widget.taskDes != " ")
                      ? Text(widget.taskDes, style: TextStyle(color: Colors.white,fontSize: 25),textAlign: TextAlign.center,maxLines: 7,)
                      : CircularProgressIndicator(
                    backgroundColor: Colors.black,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
                      child: Opacity(
                        opacity:
                        (widget.completedDays.contains(widget.index)) ? 0 : 1,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:  MaterialStateProperty.all(Colors.red),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                    )
                                )
                            ),
                          onPressed: () {
                            if (!widget.isCustom) {
                              FirebaseFirestore.instance
                                  .collection(
                                  'user+${appwrite.currentUser.$id}')
                                  .doc(widget.habitName)
                                  .update({
                                'CompletedDays': FieldValue.arrayUnion(
                                    [widget.index as dynamic])
                              }).then((value) {
                                setState(() {
                                  widget.completedDays.add(widget.index);
                                });
                              });
                            } else {
                              FirebaseFirestore.instance
                                  .collection(
                                  'user+${appwrite.currentUser.$id}')
                                  .doc('CustomHabits')
                                  .collection(widget.habitName)
                                  .doc('details')
                                  .update({
                                'CompletedDays': FieldValue.arrayUnion(
                                    [widget.index as dynamic])
                              }).then((value) {
                                setState(() {
                                  widget.completedDays.add(widget.index);
                                });
                              });
                            }
                          },
                          child: Text(
                            'Task completed!',
                            style: TextStyle(color: Colors.white),
                          ),

                        ),
                      ),
                    ),
                    Center(
                      child: Opacity(
                        opacity:
                        (widget.completedDays.contains(widget.index)) ? 1 : 0,
                        child: const Icon(
                          Icons.check,
                          size: 30,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    appwrite = context.read<AuthAPI>();
    super.initState();
    if (widget.isCustom == true) {
      print(widget.habitName);
      print('Task ${widget.index}');
      FirebaseFirestore.instance
          .collection('user+${appwrite.currentUser.$id}')
          .doc('CustomHabits')
          .collection(widget.habitName)
          .doc('details')
          .get()
          .then((det) {
        print(det.data());
        setState(() {
          widget.taskDes = det.data()!['Task ${widget.index}'];
          widget.completedDays = det.data()!['CompletedDays'];
        });
      });
    }
  }
}