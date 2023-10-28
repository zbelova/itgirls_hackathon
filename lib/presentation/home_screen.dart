import 'package:flutter/material.dart';
import 'package:itgirls_hackathon/data/model/user_model.dart';
import 'package:itgirls_hackathon/presentation/pomodoro_screen.dart';
import '../data/datasource/auth_datasource.dart';
import '../data/datasource/firebase_datasource.dart';
import '../data/model/task_model.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  FirebaseDatasource _tasksDatasource = FirebaseDatasource();
  AuthDatasource _authDatasource = AuthDatasource();
  UserModel? user;

  @override
  void initState() {
    super.initState();

    // _notesDatasource.write(Task(
    //     title: 'Доделать задачи по хакатону',
    //     description: 'Сделать экран списка задач. Экран помидорного таймера, где таймер будет отображать текущее оставшееся время. Можно поставить на паузу',
    //     isDone: false,
    //     duration: 4));
    _initData();
    _initUser();
  }

  void _initUser() async {
    user = await _authDatasource.getUser();
    setState(() {});
  }

  void _initData() {
    _tasksDatasource.readAll().listen((event) {
      final map = event.snapshot.value as Map<dynamic, dynamic>?;
      if (map != null) {
        if (mounted) {
          setState(() {
            _tasks = map.entries
                .map((e) => Task(
                      key: e.key as String,
                      title: e.value['title'] as String,
                      description: e.value['description'] as String,
                      isDone: e.value['isDone'] as bool,
                      duration: e.value['duration'] as int,
                    ))
                .toList();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff69e1ff),
            Color(0xffec52b3),
          ],
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              //add new task
              showGeneralDialog(
                  context: context,
                  pageBuilder: (context, anim1, anim2) {
                    var _nameController = TextEditingController();
                    var _descriptionController = TextEditingController();
                    var _durationController = TextEditingController();
                    return AlertDialog(
                      title: const Text('Добавить задачу'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: 'Название',
                            ),
                          ),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Описание',
                            ),
                          ),
                          TextField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Время в минутах',
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () {
                            _tasksDatasource.write(Task(title: _nameController.text, description: _descriptionController.text, isDone: false, duration: int.parse(_durationController.text)));
                            Navigator.pop(context);
                          },
                          child: const Text('Добавить'),
                        ),
                      ],
                    );
                  });
            },
            child: const Icon(Icons.add),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 15, bottom: 20),
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: const Color(0xffb9f4ff)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (user != null) ...[
                              Text(
                                'Привет, ${user!.name}',
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Icon(
                                Icons.person,
                                size: 25,
                                color: Colors.pink[500],
                              ),
                              InkWell(
                                onTap: () async {
                                  await _authDatasource.logout();
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                                },
                                child: Text(
                                  '(выйти)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.pink[500],
                                  ),
                                ),
                              )
                            ] else ...[
                              const CircularProgressIndicator()
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, bottom: 10),
                    child: Container(
                      child: const Text(
                        'Задачи',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                if (!_tasks[index].isDone) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PomodoroScreen(
                                        task: _tasks[index],
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: ListTile(
                                title: Text(
                                  _tasks[index].title,
                                  style: const TextStyle(fontSize: 17),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _tasks[index].description,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.grey[300],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                        child: Text(
                                          formatMinutes(_tasks[index].duration),
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: (_tasks[index].isDone)
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Color(0xff6fff87),
                                        size: 30,
                                      )
                                    : Icon(
                                        Icons.play_arrow,
                                        color: Colors.blue[700],
                                        size: 30,
                                      ),
                              ),
                            ),
                           Align(
                              alignment: Alignment.centerLeft,
                              child:InkWell(
                                onTap: () {
                                  _tasksDatasource.remove(_tasks[index].key!);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(left:12, top:3, bottom: 3),
                                  child: Row(
                                    children: [
                                      Icon(
                                          Icons.delete,
                                          color: Colors.blueGrey[600],
                                          size: 20,
                                        ),
                                      SizedBox(width: 3,),
                                      Text('Удалить',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.blueGrey[600],
                                        ),),
                                    ],
                                  ),
                                ),
                              ),

                            ),
                            const Divider(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String formatMinutes(int minutes) {
  if (minutes % 10 == 1 && minutes % 100 != 11) {
    return '$minutes минута';
  } else if (minutes % 10 >= 2 && minutes % 10 <= 4 && (minutes % 100 < 10 || minutes % 100 >= 20)) {
    return '$minutes минуты';
  } else {
    return '$minutes минут';
  }
}
