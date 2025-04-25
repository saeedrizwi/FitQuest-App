
import 'package:flutter_bloc/flutter_bloc.dart';


enum LatraiseState { neutral, init, complete, tooHigh }

class LatraiseCounter extends Cubit<LatraiseState> {
  LatraiseCounter() : super(LatraiseState.neutral);
  int counter = 0;

  void setUpLatraiseState(LatraiseState current) {
    print("emittedState ${state}");
    emit(current);
  }

  void increment() {
    counter++;
    print("Counter ${counter}");
    emit(state);
  }
  void decrement() {
    counter--;
    emit(state);
  }

  void reset() {
    counter = 0;
    emit(state);
  }
}

