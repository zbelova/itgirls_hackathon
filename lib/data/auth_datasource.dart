import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthDatasource {
  Future<String> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      // print(user);
      //UserPreferences().setUserAccessToken(user.credential!.accessToken!);
      return "success";
    } on FirebaseAuthException catch (e) {
      // Код ошибка для случая, если пользователь не найден
      return e.code;
    }

  }


  //регистрация пользователя
  Future<String> signUp(String email, String password, String name) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final id = FirebaseAuth.instance.currentUser?.uid;
      if (id == null) return "Ошибка";
      // Берём ссылку на корень дерева с записями для текущего пользователя
      final ref = FirebaseDatabase.instance.ref("users/$id");
      // Сначала генерируем новую ветку с помощью push() и потом в эту же ветку
      // добавляем запись

      await ref.set({'email': email, 'fullName': name});

      return "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Пароль слишком простой.';
      } else if (e.code == 'email-already-in-use') {
        return 'Пользователь с таким email уже существует.';
      } else if (e.code == 'invalid-email') {
        return 'Неверный email.';
      }
    } catch (e) {
      return "Ошибка";
    }
    return "Ошибка";
  }



  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  // Метод для изменения пароля пользователя
  Future<bool> changePassword(String email, String currentPassword, String newPassword) async {
    User user = FirebaseAuth.instance.currentUser!; // Получаем текущего пользователя

    // Создаем объект учетных данных для проведения проверки подлинности
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: currentPassword);

    try {
      // Проверяем подлинность пользователя с использованием текущих учетных данных
      await user.reauthenticateWithCredential(credential);

      // Меняем пароль на новый
      await user.updatePassword(newPassword);
      return true;
    } catch(e) {
      // print(e);
      // В случае ошибки выводим сообщение об ошибке
      return false;
    }
  }

  bool isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }
// get user

}