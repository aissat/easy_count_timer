// ignore_for_file: public_member_api_docs, sort_constructors_first
library flutter_timer_countdown;

import 'dart:async';

import 'package:flutter/widgets.dart';

enum CountTimerFormat {
  daysHoursMinutesSeconds,
  daysHoursMinutes,
  daysHours,
  daysOnly,
  hoursMinutesSeconds,
  hoursMinutes,
  hoursOnly,
  minutesSeconds,
  minutesOnly,
  secondsOnly,
}

class CountTimerController extends ChangeNotifier {
  /// Defines the time when the timer is over.
  final DateTime? endTime;

  CountTimerController({this.endTime});

  Timer? _timer;
  Duration _duration = Duration.zero;
  Duration _pause = Duration.zero;

  bool _isEnd = false;

  bool get isActive => _timer != null && _timer!.isActive;

  Duration get duration => _duration;
  bool get isEnd {
    assert(endTime == null, 'endTime must be null to get isEnd');
    return _isEnd;
  }

  void _startTimer() {
    if (endTime == null || endTime!.isBefore(DateTime.now())) {
      _duration = _duration;
    } else {
      _duration = endTime!.difference(DateTime.now());
    }

    if (_timer != null &&
        (_timer!.isActive || (!_timer!.isActive && _duration > Duration.zero)))
      return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (endTime != null) {
        _duration = endTime!.difference(DateTime.now());
        if (_duration <= Duration.zero) {
          _isEnd = true;
          _timer?.cancel();
        }
        notifyListeners();
      } else {
        _duration = _pause + Duration(seconds: timer.tick);
        notifyListeners();
      }
    });
  }

  void start() {
    assert(endTime == null, 'endTime must be null to start');
    if (_timer != null) return;
    if (_timer == null || !_timer!.isActive) {
      _startTimer();
    }
  }

  void stop() {
    assert(endTime == null, 'endTime must be null to stop');
    if (_timer != null && _timer!.isActive) {
      _timer?.cancel();
    }
    _duration = Duration.zero;
    _pause = Duration.zero;
    notifyListeners();
  }

  void reset() {
    assert(endTime == null, 'endTime must be null to reset');
    _duration = Duration.zero;
    _pause = Duration.zero;
    if (_timer != null) {
      _timer?.cancel();
    }
    notifyListeners();
  }

  void restart() {
    assert(endTime == null, 'endTime must be null to reset');
    _duration = Duration.zero;
    _pause = Duration.zero;
    if (_timer != null) {
      _timer?.cancel();
      start();
    }
    notifyListeners();
  }

  void puase() {
    assert(endTime == null, 'endTime must be null to puase');
    debugPrint('CountTimerController start Duartion: ${_duration.inSeconds}');
    _timer?.cancel();
    _pause = _duration;
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }
}

class CountTimer extends StatefulWidget {
  /// Format for the timer coundtown, choose between different `CountTimerFormat`s

  final CountTimerFormat format;

  /// Function to call when the timer is over.
  final VoidCallback? onEnd;

  /// Toggle time units descriptions.
  final bool enableDescriptions;

  /// `TextStyle` for the time numbers.
  final TextStyle? timeTextStyle;

  /// `TextStyle` for the colons betwenn the time numbers.
  final TextStyle? colonsTextStyle;

  /// `TextStyle` for the description
  final TextStyle? descriptionTextStyle;

  /// Days unit description.
  final String daysDescription;

  /// Hours unit description.
  final String hoursDescription;

  /// Minutes unit description.
  final String minutesDescription;

  /// Seconds unit description.
  final String secondsDescription;

  /// Defines the width between the colons and the units.
  final double spacerWidth;

  //
  final CountTimerController controller;

  const CountTimer({
    Key? key,
    this.format = CountTimerFormat.daysHoursMinutesSeconds,
    this.onEnd,
    this.enableDescriptions = true,
    this.timeTextStyle,
    this.colonsTextStyle,
    this.descriptionTextStyle,
    this.daysDescription = "Days",
    this.hoursDescription = "Hours",
    this.minutesDescription = "Minutes",
    this.secondsDescription = "Seconds",
    this.spacerWidth = 10,
    required this.controller,
  }) : super(key: key);

  @override
  State<CountTimer> createState() => _CountTimerState();
}

class _CountTimerState extends State<CountTimer> {
  late String countdownDays;
  late String countdownHours;
  late String countdownMinutes;
  late String countdownSeconds;
  late Duration difference;

  @override
  void initState() {
    widget.controller._startTimer();
    difference = widget.controller.duration;
    print(difference);
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {
          difference = widget.controller.duration;
          countdownDays = _durationToStringDays(difference);
          countdownHours = _durationToStringHours(difference);
          countdownMinutes = _durationToStringMinutes(difference);
          countdownSeconds = _durationToStringSeconds(difference);
        });
      }
      if (widget.controller._isEnd) {
        widget.onEnd!();
      }
    });

    countdownDays = _durationToStringDays(difference);
    countdownHours = _durationToStringHours(difference);
    countdownMinutes = _durationToStringMinutes(difference);
    countdownSeconds = _durationToStringSeconds(difference);

    super.initState();
  }

  @override
  void dispose() {
    // widget.controller.dispose();
    print(widget.controller.duration);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _countTimerFormat();
  }

  /// When the selected [CountTimerFormat] is leaving out the last unit, this function puts the UI value of the unit before up by one.
  ///
  /// This is done to show the currently running time unit.
  String _twoDigits(int n, String unitType) {
    switch (unitType) {
      case "minutes":
        if (widget.format == CountTimerFormat.daysHoursMinutes ||
            widget.format == CountTimerFormat.hoursMinutes ||
            widget.format == CountTimerFormat.minutesOnly) {
          if (difference > Duration.zero) {
            n++;
          }
        }
        if (n >= 10) return "$n";
        return "0$n";
      case "hours":
        if (widget.format == CountTimerFormat.daysHours ||
            widget.format == CountTimerFormat.hoursOnly) {
          if (difference > Duration.zero) {
            n++;
          }
        }
        if (n >= 10) return "$n";
        return "0$n";
      case "days":
        if (widget.format == CountTimerFormat.daysOnly) {
          if (difference > Duration.zero) {
            n++;
          }
        }
        if (n >= 10) return "$n";
        return "0$n";
      default:
        if (n >= 10) return "$n";
        return "0$n";
    }
  }

  /// Convert [Duration] in days to String for UI.
  String _durationToStringDays(Duration duration) {
    return _twoDigits(duration.inDays, "days").toString();
  }

  /// Convert [Duration] in hours to String for UI.
  String _durationToStringHours(Duration duration) {
    if (widget.format == CountTimerFormat.hoursMinutesSeconds ||
        widget.format == CountTimerFormat.hoursMinutes ||
        widget.format == CountTimerFormat.hoursOnly) {
      return _twoDigits(duration.inHours, "hours");
    } else {
      return _twoDigits(duration.inHours.remainder(24), "hours").toString();
    }
  }

  /// Convert [Duration] in minutes to String for UI.
  String _durationToStringMinutes(Duration duration) {
    if (widget.format == CountTimerFormat.minutesSeconds ||
        widget.format == CountTimerFormat.minutesOnly) {
      return _twoDigits(duration.inMinutes, "minutes");
    } else {
      return _twoDigits(duration.inMinutes.remainder(60), "minutes");
    }
  }

  /// Convert [Duration] in seconds to String for UI.
  String _durationToStringSeconds(Duration duration) {
    if (widget.format == CountTimerFormat.secondsOnly) {
      return _twoDigits(duration.inSeconds, "seconds");
    } else {
      return _twoDigits(duration.inSeconds.remainder(60), "seconds");
    }
  }

  /// Builds the UI colons between the time units.
  Widget _colon() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.spacerWidth),
      child: _TimerColumn(
        value: ':',
        // int.parse(countdownSeconds) % 2 == 0 ? ':' : ' ',
        timeTextStyle: widget.colonsTextStyle,
        description: '',
        descriptionTextStyle: widget.descriptionTextStyle,
        enableDescriptions: widget.enableDescriptions,
      ),
    );
  }

  /// Builds the UI of the time units.
  _timeColumn({required String value, required String description}) =>
      _TimerColumn(
        value: value,
        description: description,
        descriptionTextStyle: widget.descriptionTextStyle,
        timeTextStyle: widget.timeTextStyle,
        enableDescriptions: widget.enableDescriptions,
      );

  /// Switches the UI to be displayed based on [CountTimerFormat].
  Widget _countTimerFormat() {
    return switch (widget.format) {
      CountTimerFormat.daysHoursMinutesSeconds => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _timeColumn(
              value: countdownDays,
              description: widget.daysDescription,
            ),
            _colon(),
            _timeColumn(
              value: countdownHours,
              description: widget.hoursDescription,
            ),
            _colon(),
            _timeColumn(
              value: countdownMinutes,
              description: widget.minutesDescription,
            ),
            _colon(),
            _timeColumn(
              value: countdownSeconds,
              description: widget.secondsDescription,
            ),
          ],
        ),
      CountTimerFormat.daysHoursMinutes => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _timeColumn(
              value: countdownDays,
              description: widget.daysDescription,
            ),
            _colon(),
            _timeColumn(
              value: countdownHours,
              description: widget.hoursDescription,
            ),
            _colon(),
            _timeColumn(
              value: countdownMinutes,
              description: widget.minutesDescription,
            ),
          ],
        ),
      CountTimerFormat.daysHours => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _timeColumn(
              value: countdownDays,
              description: widget.daysDescription,
            ),
            _colon(),
            _timeColumn(
              value: countdownHours,
              description: widget.hoursDescription,
            ),
          ],
        ),
      CountTimerFormat.daysOnly => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _timeColumn(
              value: countdownDays,
              description: widget.daysDescription,
            ),
          ],
        ),
      CountTimerFormat.hoursMinutesSeconds => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _timeColumn(
              value: countdownHours,
              description: widget.hoursDescription,
            ),
            _colon(),
            _timeColumn(
              value: countdownMinutes,
              description: widget.minutesDescription,
            ),
            _colon(),
            _timeColumn(
              value: countdownSeconds,
              description: widget.secondsDescription,
            ),
          ],
        ),
      CountTimerFormat.hoursMinutes => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _timeColumn(
              value: countdownHours,
              description: widget.hoursDescription,
            ),
            _colon(),
            _timeColumn(
              value: countdownMinutes,
              description: widget.minutesDescription,
            ),
          ],
        ),
      CountTimerFormat.hoursOnly => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _timeColumn(
              value: countdownHours,
              description: widget.hoursDescription,
            ),
          ],
        ),
      CountTimerFormat.minutesSeconds => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _timeColumn(
              value: countdownMinutes,
              description: widget.minutesDescription,
            ),
            _colon(),
            _timeColumn(
              value: countdownSeconds,
              description: widget.secondsDescription,
            ),
          ],
        ),
      CountTimerFormat.minutesOnly => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _timeColumn(
              value: countdownMinutes,
              description: widget.minutesDescription,
            ),
          ],
        ),
      CountTimerFormat.secondsOnly => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _timeColumn(
              value: countdownSeconds,
              description: widget.secondsDescription,
            ),
          ],
        ),
    };
  }
}

class _TimerColumn extends StatelessWidget {
  const _TimerColumn({
    required this.value,
    this.timeTextStyle,
    this.descriptionTextStyle,
    this.enableDescriptions = true,
    this.description,
  }) : assert(enableDescriptions != true || description != null,
            'description must not be null when enableDescriptions is true');
  final String value;
  final TextStyle? timeTextStyle;
  final String? description;
  final TextStyle? descriptionTextStyle;
  final bool enableDescriptions;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: timeTextStyle,
        ),
        if (enableDescriptions)
          Text(
            "$description",
            style: descriptionTextStyle,
          ),
      ],
    );
  }
}
