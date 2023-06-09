import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habit_pro/screens/LoginScreen.dart';
import 'package:habit_pro/utils/widgets/alertDialog.dart';
import 'package:provider/provider.dart';
import '../appwrite/auth_api.dart';

class Profile extends StatefulWidget {
  String? name;
  dynamic gender;
  int? index;
  List<dynamic>? allIncompleteHabits ;

  Profile(this.name, this.gender, this.allIncompleteHabits);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  @override
  Widget build(BuildContext context) {
    final AuthAPI appwrite = context.read<AuthAPI>();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title:  Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Profile'),
              (widget.name!="Anonymous")?
              TextButton.icon(onPressed: (){
                showAlert(title: "Signing Out", text: "Trying to sign you out.", actions: false, context: context);
                appwrite.signOut().then((value) {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context){
                    return LoginScreen();
                  }), (r){
                    return false;
                  });
                });
              },label: const Text("Logout",style: TextStyle(color: Colors.white,fontSize: 18),),icon: const Icon(Icons.logout,color: Colors.white),)
                  :Container()
            ],
          ),
          backgroundColor: Colors.red,
        ),
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            ClipPath(
              clipper: MyClipper(),
              child: Container(
                color: Colors.red,
                height: 300,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 100,
                        height: 100,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: SvgPicture.asset(
                              (widget.gender == 'Male')
                                  ? 'assets/person.svg'
                                  : 'assets/woman.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Text('${widget.name}',overflow: TextOverflow.ellipsis,style: const TextStyle(color: Colors.white,fontSize: 24),),
                      const SizedBox(height: 24,),
                      const SizedBox(
                      height: 30,
                        child: Center(
                            child: Text(
                              'Not started habits:',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Container(
                margin: const EdgeInsets.only(top: 200),
                child: ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: widget.allIncompleteHabits!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 50,
                        color: Colors.white,
                        child: Center(
                          child: Text('${widget.allIncompleteHabits![index]}'),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                    const Divider()),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const AlertDialog(
                backgroundColor: Colors.white,
                title: Icon(Icons.email,size: 40,color: Colors.red,),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Email us your queries at:'),
                    Card(child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text('akanshchoudhary79@gmail.com',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                    )),
                    Card(child: Padding(
                      padding: EdgeInsets.all(10.0),
                      //todo: change email id
                      child: Text('harshvs415@gmail.com',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                    )),
                  ],
                ),
              ),
            );
          },
          child: Icon(Icons.help),
          backgroundColor: Colors.red,
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