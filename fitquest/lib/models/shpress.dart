
import 'package:flutter_bloc/flutter_bloc.dart';


enum ShoulderPressState { neutral, init, complete }

class ShoulderPressCounter extends Cubit<ShoulderPressState> {
  ShoulderPressCounter() : super(ShoulderPressState.neutral);
  int counter = 0;

  void setUpShoulderPressState(ShoulderPressState current) {
    print("emittedState ${state}");
    emit(current);
  }

  void increment() {
    counter++;
    print("Counter ${counter}");
    emit(state);
  }

  void reset() {
    counter = 0;
    emit(state);
  }
}

