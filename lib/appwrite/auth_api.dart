import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/widgets.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}



class AuthAPI extends ChangeNotifier {
  Client client = Client();
  late  final Account account;

  late User _currentUser;

  AuthStatus _status = AuthStatus.uninitialized;

  // Getter methods
  User get currentUser => _currentUser;
  AuthStatus get status => _status;

  // Constructor
  AuthAPI() {
    init();
    loadUser();
  }


  init() {
    client
        .setEndpoint("https://cloud.appwrite.io/v1")
        .setProject("6475c0669522a8aa5a93")
        .setSelfSigned(status: true);
    account = Account(client);
  }

  loadUser() async {
    try {
      final user = await account.get();
      _status = AuthStatus.authenticated;
      _currentUser = user;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<List<dynamic>> createUser(
      {required String email, required String password}) async {
    try {
      final user = await account.create(
          userId: ID.unique(),
          email: email,
          password: password);
      final response = await createEmailSession(email: email, password: password);
      if(response[0]!=null){
        return [response[0],user];
      }else{
        return [null,null];
      }

    } finally {
      notifyListeners();
    }
  }

  Future<List<dynamic>> createEmailSession(
      {required String email, required String password}) async {
    try {
      final session = await account.createEmailSession(email: email, password: password);
      _currentUser = await account.get();
      _status = AuthStatus.authenticated;
      return [session,""];
    } catch(e){
      print(e.toString());
      return [null,"Please try again with correct email and password"];
    }finally {
      notifyListeners();
    }
  }

  Future<Session> createAnonymousSession() async {
    try {
      final session = await account.createAnonymousSession();
      _currentUser = await account.get();
      print(_currentUser);
      _status = AuthStatus.authenticated;
      return session;
    } finally {
      notifyListeners();
    }
  }
  Future<List<dynamic>> signInWithProvider({required String provider}) async {
    try {
      final session = await account.createOAuth2Session(provider: provider);
      _currentUser = await account.get();
      _status = AuthStatus.authenticated;
      return [_currentUser.$id,_currentUser.name];
    }
    catch(e){
      return [null,"Error"];
    }finally {
      notifyListeners();
    }
  }

  Future signOut() async {
    try {
      final session  = await account.deleteSession(sessionId: 'current');
      _status = AuthStatus.unauthenticated;
      return session;
    } finally {
      notifyListeners();
    }
  }

  Future<Preferences> getUserPreferences() async {
    return await account.getPrefs();
  }

  updatePreferences({required String bio}) async {
    return account.updatePrefs(prefs: {'bio': bio});
  }
}
