import 'package:flutter/cupertino.dart';

import 'package:easy_count_timer/easy_count_timer.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.light,
      ),
      home: CupertinoPageScaffold(
        child: SafeArea(minimum: EdgeInsets.all(20), child: CounterUpTimer()),
      ),
    );
  }
}

class CounterUpTimer extends StatefulWidget {
  const CounterUpTimer({super.key});

  @override
  State<CounterUpTimer> createState() => _CounterUpTimerState();
}

class _CounterUpTimerState extends State<CounterUpTimer> {
  var controller = CountTimerController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoPageScaffold(
          child: CountTimer(
            format: CountTimerFormat.daysHoursMinutesSeconds,
            controller: CountTimerController(),
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
              onPressed: () {
                controller.start();
              },
              icon: const Icon(Icons.play_arrow_rounded)),
          IconButton(
              onPressed: () {
                controller.pause();
              },
              icon: const Icon(Icons.pause_rounded)),
          IconButton(
              onPressed: () {
                controller.stop();
              },
              icon: const Icon(Icons.stop_rounded)),
          IconButton(
              onPressed: () {
                controller.reset();
              },
              icon: const Icon(Icons.restart_alt_rounded)),
        ]),
      ],
    );
  }
}
