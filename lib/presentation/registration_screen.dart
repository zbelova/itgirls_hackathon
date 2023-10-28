import 'package:flutter/material.dart';
import 'package:itgirls_hackathon/data/datasource/auth_datasource.dart';
import '../main.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordAgainController = TextEditingController();
  List<String> resultCheck = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 0),
              child: Column(
                children: [
                  _buildTextFormField(
                      controller: _nameController,
                      context: context,
                      labelText: 'Имя'),
                  _buildTextFormField(controller: _emailController, context: context, labelText: 'Электронная почта'),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      obscuringCharacter: '*',
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _passwordAgainController,
                    obscureText: true,
                    obscuringCharacter: '*',
                    decoration: const InputDecoration(
                      labelText: 'Подтверждение пароля',
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                resultCheck = _checkRegistration(
                     nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    passwordAgainController: _passwordAgainController)!;
                if (resultCheck.isNotEmpty) {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Проверьте данные'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < resultCheck.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  '- ${resultCheck[i]}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                          ],
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            child: const Text('ОК'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  _register();
                }
              },
              child: const Text(
                'Зарегистрироваться',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    String result;

    try {
      result = await getIt.get<AuthDatasource>().signUp(_emailController.text, _passwordController.text, _nameController.text);
      if (result == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _buildErrorMessage(result);
      }
    } catch (e) {
      _buildErrorMessage(e.toString());
      //print('Ошибка при входе: $e');
    }
  }

  Future<void> _buildErrorMessage(String message) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ошибка регистрации'),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('ОК'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

List<String>? _checkRegistration(
    {
       required TextEditingController nameController,

    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController passwordAgainController}) {
  List<String> error = [];
   String? name = nameController.text;

  String? email = emailController.text;
  String? password = passwordController.text;
  String? passwordAgain = passwordAgainController.text;
  if (
   name == '' ||
      email == '' || password == '' || passwordAgain == '') {
    error.add('Не все поля заполнены');

  }
  if (validateEmail(email) != 1) {
    error.add('Ошибка в формате электронной почты');

  }
  if (password != passwordAgain) {
    error.add('Пароли не совпадают');

  }
  return error;
}

Widget _buildTextFormField({required TextEditingController controller, required BuildContext context, bool isEdited = false, required String labelText}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        enabledBorder: isEdited
            ? OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              )
            : UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
        focusedBorder: isEdited
            ? const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              )
            : UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
      ),
    ),
  );
}

int validateEmail(String value) {
  String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(value)) {
    return 0;
  } else {
    return 1;
  }
}

