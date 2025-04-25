
// Define a base state for both counters (you can have more complex states if needed)
import 'package:flutter_bloc/flutter_bloc.dart';

enum BicepsCurlState { neutral, init, complete }

class BicepsCurlCounter extends Cubit<BicepsCurlState> {
  BicepsCurlCounter() : super(BicepsCurlState.neutral);
  int counter = 0;

  void setUpBicepsCurlState(BicepsCurlState current) {
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
