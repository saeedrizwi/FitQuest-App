import 'dart:io';
import 'dart:math' as math;
import 'dart:math';
import 'camera_view.dart';


import 'package:flutter/services.dart';






import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fitquest/models/latraise.dart';
import 'package:fitquest/models/squat.dart';
import 'package:fitquest/models/triext.dart';
import 'package:fitquest/models/shpress.dart';
import 'package:fitquest/models/bicurl.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';


Future<String> getAssetPath(String asset) async {
  final path = await getLocalPath(asset);
  await Directory(dirname(path)).create(recursive: true);
  final file = File(path);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(asset);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }
  return file.path;
}

Future<String> getLocalPath(String path) async {
  return '${(await getApplicationSupportDirectory()).path}/$path';
}
double angle(PoseLandmark firstLandmark, PoseLandmark midLandmark,
    PoseLandmark lastLandmark) {
  double radians = atan2(
      lastLandmark.y - midLandmark.y, lastLandmark.x - midLandmark.x) -
      atan2(firstLandmark.y - midLandmark.y, firstLandmark.x - midLandmark.x);
  double degrees = radians * 180.0 / math.pi;
  degrees = degrees.abs(); // Angle should never be negative
  if (degrees > 180.0) {
    degrees =
        360.0 - degrees; // Always get the acute representation of the angle
  }
  return degrees;
}

ShoulderPressState? isShoulderPress(double RangleElbow,double LangleElbow,double rConAngle,double lconAngle, ShoulderPressState current) {
  final umbralElbow = 60.0;
  final umbralElbowExt = 130.0;

  print(
      "First ${current}==${ShoulderPressState.neutral} && ${RangleElbow}>${umbralElbowExt} && ${RangleElbow}< 180.0");
  print(
      "Second ${current}==${ShoulderPressState.init} && ${RangleElbow}<${umbralElbow} && ${RangleElbow}< 40.0");

  if (current == ShoulderPressState.neutral &&
      RangleElbow < umbralElbow && LangleElbow < umbralElbow &&
      RangleElbow > 40.0 && LangleElbow > 40.0 && rConAngle > 30.0 && lconAngle > 30.0
      ) {
    return ShoulderPressState.init;
  } else if (current == ShoulderPressState.init &&
      RangleElbow > umbralElbowExt && LangleElbow > umbralElbowExt && LangleElbow < 180.0 &&
      RangleElbow < 180.0 && rConAngle > 30.0 && lconAngle > 30.0
      ) {
    return ShoulderPressState.complete;}
  else if (current == ShoulderPressState.complete &&
      RangleElbow > umbralElbowExt && LangleElbow > umbralElbowExt && rConAngle > 30.0 && lconAngle > 30.0) {
    return ShoulderPressState.init; // Start another press
  }


}

BicepsCurlState? isBicepsCurl(double RangleElbow,double LangleElbow,double rHipAngle,double lHipAngle, BicepsCurlState current) {
  final umbralElbow = 90.0;
  final umbralElbowExt = 160.0;

  print(
      "First ${current}==${BicepsCurlState.neutral} && ${RangleElbow}>${umbralElbowExt} && ${RangleElbow}< 180.0");
  print(
      "Second ${current}==${BicepsCurlState.init} && ${RangleElbow}<${umbralElbow} && ${RangleElbow}< 40.0");

  if (current == BicepsCurlState.neutral &&
      RangleElbow < 180 && LangleElbow < 180 &&
      RangleElbow > umbralElbowExt && LangleElbow > umbralElbowExt
  ) {
    return BicepsCurlState.init;
  } else if (current == BicepsCurlState.init &&
      RangleElbow > 40 && LangleElbow > 40 &&
      RangleElbow < umbralElbow && LangleElbow < umbralElbow
  ) {
    return BicepsCurlState.complete;}
  else if (current == BicepsCurlState.complete &&
      RangleElbow > umbralElbowExt && LangleElbow > umbralElbowExt ) {
    return BicepsCurlState.init; // Start another press
  }



}

LatraiseState? isLatraise(double RangleShoulder,double LangleShoulder,  LatraiseState current) {

    final  low = 20.0;   // Arms mostly down
    final  high = 80.0;
    final max=115.0;// Arms nearly horizontal

    print("Checking: ${current} with angle ${RangleShoulder}");


  if(LangleShoulder>max || RangleShoulder>max){
    return LatraiseState.tooHigh;}
 /* else if(current==LatraiseState.tooHigh){
    return LatraiseState.init;
  }

  */

   else if (current == LatraiseState.neutral && RangleShoulder > low && RangleShoulder < 40 && LangleShoulder >low && LangleShoulder <40) {
      return LatraiseState.init; // Start raising
    }
    else if (current == LatraiseState.init &&
     RangleShoulder>high && LangleShoulder>high && LangleShoulder<max && RangleShoulder < max){
      return LatraiseState.complete; // Reached top position
    }

    else if (current == LatraiseState.complete && RangleShoulder < low && LangleShoulder < low) {
      return LatraiseState.neutral; }// Only reset when arms return DOWN


    return current; // Maintain state if no transition occurs
  }





SquatState? isSquat(double angleKnee, SquatState current) {
  final low = 100.0;
  final high = 160.0;

  print(
      "First ${current}==${SquatState.neutral} && ${angleKnee}>${high} && ${angleKnee}< 180.0");
  print(
      "Second ${current}==${SquatState.init} && ${angleKnee}<${low} && ${angleKnee}< 40.0");

  if (current == SquatState.neutral &&
      angleKnee < 180 &&
      angleKnee > high
  ) {
    return SquatState.init;
  } else if (current == SquatState.init &&
      angleKnee > 40 &&
      angleKnee < low
  ) {
    return SquatState.complete;}
  else if (current == SquatState.complete &&
      angleKnee > high) {
    return SquatState.init; // Start another press
  }



}

TricExtState? isTriExt(double RangleElbow,double LangleElbow,double lconAngle,double rconAngle,  TricExtState current) {
  final umbralElbow = 80.0;
  final umbralElbowExt = 100.0;

  print(
      "First ${current}==${TricExtState.neutral} && ${RangleElbow}>${umbralElbowExt} && ${RangleElbow}< 180.0");
  print(
      "Second ${current}==${TricExtState.init} && ${RangleElbow}<${umbralElbow} && ${RangleElbow}< 40.0");
if(lconAngle > 130 && rconAngle > 130) {
  if (current == TricExtState.neutral &&
      RangleElbow < umbralElbow && LangleElbow < umbralElbow &&
      RangleElbow > 40.0 && LangleElbow > 40
      && lconAngle > 90 && rconAngle > 90
  ) {
    return TricExtState.init;
  } else if (current == TricExtState.init &&
      RangleElbow > umbralElbowExt && LangleElbow > umbralElbowExt &&
      RangleElbow < 180.0 && LangleElbow < 180
      && lconAngle > 90 && rconAngle > 90
  ) {
    return TricExtState.complete;
  }
  else if (current == TricExtState.complete &&
      RangleElbow > umbralElbowExt && LangleElbow > umbralElbowExt) {
    return TricExtState.init; // Start another press
  }
}


}