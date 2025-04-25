
import 'package:flutter_bloc/flutter_bloc.dart';


enum TricExtState { neutral, init, complete }

class TriExtCounter extends Cubit<TricExtState> {
  TriExtCounter() : super(TricExtState.neutral);
  int counter = 0;

  void setUpRowState(TricExtState current) {
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

