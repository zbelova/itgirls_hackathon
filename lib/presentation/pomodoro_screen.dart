import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:itgirls_hackathon/data/datasource/firebase_datasource.dart';

import '../data/model/task_model.dart';
import 'home_screen.dart';

class PomodoroScreen extends StatefulWidget {
  Task task;

  PomodoroScreen({super.key, required this.task});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  late FlutterLocalNotificationsPlugin localNotifications;
  bool _timerRunning = false;
  Timer? _timer;
  int _current = 0;
  FirebaseDatasource _tasksDatasource = GetIt.I.get();

  @override
  void initState() {
    super.initState();
    _current = widget.task.duration;
    //объект для Android настроек
    const androidInitialize = AndroidInitializationSettings('ic_launcher');
    //объект для IOS настроек
    const iOSInitialize = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    // общая инициализация
    const initializationSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);

    //мы создаем локальное уведомление
    localNotifications = FlutterLocalNotificationsPlugin();
    localNotifications.initialize(initializationSettings);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _timerRunning = true;
    });

    var duration = const Duration(seconds: 1);
    _timer = Timer.periodic(
      duration,
      (Timer timer) => setState(() {
        if (_current <= 0) {
          timer.cancel();
          _showNotification();
          _tasksDatasource.edit(Task(
            key: widget.task.key,
            title: widget.task.title,
            description: widget.task.description,
            isDone: true,
            duration: widget.task.duration,
          ));
          Navigator.pop(context);
        } else {
          _current--;
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xffffddd3),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              child: Text('Все задачи'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        //color: Color(0xffd8faff),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.orangeAccent,
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.task.title,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Text(widget.task.description),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),
                    Image(
                      image: const AssetImage('assets/focus.jpg'),
                      width: MediaQuery.of(context).size.width * 0.9,
                    ),
                    Container(
                      //decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: const Color(0xffc0e4ff)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          formatMinutes(_current),
                          style: const TextStyle(fontSize: 50),
                        ),
                      ),
                    ),
                    if (!_timerRunning) ElevatedButton(onPressed: _startTimer, child: const Icon(Icons.play_arrow)),
                    if (_timerRunning)
                      ElevatedButton(
                        onPressed: () {
                          _timer?.cancel();
                          setState(() {
                            _timerRunning = false;
                            //_current = widget.task.duration;
                          });
                        },
                        child: const Icon(Icons.pause),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      "ID",
      "Молодец!",
      importance: Importance.high,
      channelDescription: "Задача завершена",
    );

    const iosDetails = DarwinNotificationDetails();
    const generalNotificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await localNotifications.show(0, "Молодец!", "Можешь отдохнуть", generalNotificationDetails);
  }
}
