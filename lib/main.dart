import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';
import './bloc/bloc.dart';
import './ticker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.green,
        accentColor: Colors.amber[100],
        brightness: Brightness.dark,
      ),
      title: 'Flutter Timer',
      home: BlocProvider(
        create: (context) => TimerBloc(ticker: Ticker()),
        child: Timer(),
      ),
    );
  }
}

class Timer extends StatelessWidget {
  static const TextStyle timerTextStyle = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Flutter Timer')),
        body: Stack(
          children: [
            Background(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 100.0),
                  child: Center(
                    child: BlocBuilder<TimerBloc, TimerState>(
                      builder: (context, state) {
                        final String minutesStr = ((state.duration / 60) % 60)
                            .floor()
                            .toString()
                            .padLeft(2, '0');
                        final String secondsStr = (state.duration % 60)
                            .floor()
                            .toString()
                            .padLeft(2, '0');
                        return Text(
                          '$minutesStr:$secondsStr',
                          style: Timer.timerTextStyle,
                        );
                      },
                    ),
                  ),
                ),
                BlocBuilder<TimerBloc, TimerState>(
                  buildWhen: (previousState, state) =>
                      state.runtimeType != previousState.runtimeType,
                  builder: (context, state) => Actions(),
                ),
              ],
            ),
          ],
        ),
      );
}

class Actions extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _mapStateToActionButtons(
          timerBloc: BlocProvider.of<TimerBloc>(context),
        ),
      );

  List<Widget> _mapStateToActionButtons({
    TimerBloc timerBloc,
  }) {
    final TimerState currentState = timerBloc.state;
    if (currentState is TimerInitial) {
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () =>
              timerBloc.add(TimerStarted(duration: currentState.duration)),
        ),
      ];
    }
    if (currentState is TimerRunInProgress) {
      return [
        FloatingActionButton(
          child: Icon(Icons.pause),
          onPressed: () => timerBloc.add(TimerPaused()),
        ),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(TimerReset()),
        ),
      ];
    }
    if (currentState is TimerRunPause) {
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () => timerBloc.add(TimerResumed()),
        ),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(TimerReset()),
        ),
      ];
    }
    if (currentState is TimerRunComplete) {
      return [
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(TimerReset()),
        ),
      ];
    }
    return [];
  }
}

class Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) => WaveWidget(
        config: CustomConfig(
          gradients: [
            [
              Color.fromRGBO(255, 60, 0, .3),
              Color.fromRGBO(255, 34, 0, .5),
              Color.fromRGBO(255, 0, 0, .8)
            ],
            [
              Color.fromRGBO(255, 0, 25, .2),
              Color.fromRGBO(180, 0, 70, .5),
              Color.fromRGBO(130, 0, 90, .7)
            ],
            [
              Color.fromRGBO(255, 213, 0, .2),
              Color.fromRGBO(255, 191, 0, .4),
              Color.fromRGBO(255, 179, 0, .7)
            ],
          ],
          durations: [11000, 66000, 33000],
          heightPercentages: [0.03, 0.01, 0.02],
          gradientBegin: Alignment.bottomCenter,
          gradientEnd: Alignment.topCenter,
        ),
        size: Size(double.infinity, double.infinity),
        waveAmplitude: 25,
        backgroundColor: Colors.purple[100],
      );
}
