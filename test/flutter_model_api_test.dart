import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_model_api/flutter_model_api.dart';

httpRequestUser() {}

class User {}

class LoginAPI extends ModelAPI<LoginAPI> {
  LoginAPI({required this.inNickname, required this.inPassword});

  String inNickname;

  String inPassword;

  User? outUser;

  @override
  loading() async {
    try {
      outUser = await httpRequestUser();
    } catch (e) {
      outError = e;
    } finally {
      complete();
    }
  }
}

void main() {
  test('adds one to input values', () async {
    // LoginAPI(inNickname: 'jack', inPassword: '12345').onComplete((api) {
    //   if (api.hasError) {
    //     alert(api.outError);
    //   } else {
    //     User? currentUser = api.outUser;
    //     if (currentUser != null) {
    //       pagePush();
    //     } else {
    //       alert('User does not exist');
    //     }
    //   }
    // }).launch();
  });
}
