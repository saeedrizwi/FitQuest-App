import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import '../models/bicurl.dart';
import '../models/latraise.dart';
import '../models/triext.dart';
import '../models/shpress.dart';
import '../models/squat.dart';
//import '../pages/home.dart';
import '../pages/rewards.dart';
import '../pages/videoplayer.dart';
import '../pages/workout.dart';
import 'painters/pose_painter.dart';
import 'utils.dart';

class CameraView extends StatefulWidget {
  CameraView(
      {Key? key,
        required this.posePainter,
        required this.customPaint,
        required this.onImage,
        this.onCameraFeedReady,
        //this.onDetectorViewModeChanged,
        this.onCameraLensDirectionChanged,
        this.initialCameraLensDirection = CameraLensDirection.front,
        required this.exerciseLabel})
      : super(key: key);

  final PosePainter? posePainter;
  final String exerciseLabel;
  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  //final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late FlutterTts flutterTts;
  bool hasShownDialog = false;
  
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
 /* double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;

  */
  bool _changingCameraLens = false;
  PoseLandmark? rSh;
  PoseLandmark? rEl;
  PoseLandmark? rWr;
  PoseLandmark? rHip;
  PoseLandmark? rKnee;
  PoseLandmark? rAnkle;
  PoseLandmark? lSh;
  PoseLandmark? lEl;
  PoseLandmark? lWr;
  PoseLandmark? lHip;
  PoseLandmark? lKnee;
  PoseLandmark? lAnkle;
  int count = 0;

  @override
  void initState() {
    super.initState();
    flutterTts=FlutterTts();
    //flutterTts.awaitSpeakCompletion(true);


    _initialize();
  }
  Future<void> _handleWorkoutLogic({
    required String exerciseLabel,
    required dynamic exerciseBloc, // 👈 Accept any Bloc that has .counter

  }) async {
    if (exerciseBloc.counter >= 15 && !hasShownDialog) {
      hasShownDialog = true;

      // 🗣️ Speak with TTS
      await flutterTts.speak("Congratulations! You have completed 15 $exerciseLabel exercises.");

      // 🪙 Reward and get updated coins
      final updatedCoins = await rewardWorkoutCompletion();
      exerciseBloc.reset;
      await logCompletedWorkout(widget.exerciseLabel);
      await updateStreakIfEligible();

      print("Logging workout for: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}");// this will log the workout

      // 🎉 Show congratulations dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text("🎉 Congratulations!"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("You've completed 15 $exerciseLabel!", textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 40),
                  const SizedBox(height: 8),
                  const Text("You earned 50 coins for completing this workout."),
                  Text("Total Coins: $updatedCoins", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Close dialog
                    Navigator.of(context).pop();

                    // Then close the ShoulderPress screen
                    Navigator.of(context).pop(); // If you only need to pop one level

                    // OR: If you're unsure how deep to pop, pop until home or named route
                    // Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text("Exit"),
                ),
              ],
            );
          },
        );
      });
    }
  }

  Future<void> _speakCounter(int count) async {
    print("Speaking count: $count");
    count++;// Log to check the value being passed
    await flutterTts.speak(count.toString());
    await Future.delayed(Duration(milliseconds: 300));
    // Short delay after speaking
  }
  bool _isSpeaking = false;
Future<void> _postureCorrection(int cor) async{
  _isSpeaking = true;

    switch(cor)
        {
      case 1 : {
        await flutterTts.speak("Do not raise your elbows above your shoulders");
        await Future.delayed(Duration(seconds: 3));
       // await Future.delayed(Duration(microseconds: 300));
        break;
      }
    }
  // Simulate speak duration before allowing next
  await Future.delayed(Duration(seconds: 3));
  _isSpeaking = false;
}

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }

    // Attempt to find the front camera
    _cameraIndex = _cameras.indexWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front);

    // If no front camera, default to the first available camera
    if (_cameraIndex == -1 && _cameras.isNotEmpty) {
      _cameraIndex = 0;
    }

    // Start live feed if a valid camera is found
    if (_cameraIndex != -1) {
      _startLiveFeed();
    } else {
      debugPrint("No cameras found.");
    }
  }


  @override
  void didUpdateWidget(covariant CameraView oldWidget) {
    //bool hasShownDialog = false;
    if (widget.customPaint != oldWidget.customPaint) {
      if (widget.customPaint == null) return;

     bool _hasWarnedTooHigh = false;

      if (widget.exerciseLabel == 'Shoulder Press') {
        final press = BlocProvider.of<ShoulderPressCounter>(context);


        for (final pose in widget.posePainter!.poses) {
          PoseLandmark getPoseLandmark(PoseLandmarkType type1) {
            final PoseLandmark? joint1 = pose.landmarks[type1];
            return joint1!;
          }

          rSh = getPoseLandmark(PoseLandmarkType.rightShoulder);
          rEl = getPoseLandmark(PoseLandmarkType.rightElbow);
          rWr = getPoseLandmark(PoseLandmarkType.rightWrist);
          rHip = getPoseLandmark(PoseLandmarkType.rightHip);
          lSh= getPoseLandmark(PoseLandmarkType.leftShoulder);
          lEl = getPoseLandmark(PoseLandmarkType.leftElbow);
          lWr = getPoseLandmark(PoseLandmarkType.leftWrist);
          lHip = getPoseLandmark(PoseLandmarkType.leftHip);



        }

        //verfication
        if (rSh != null && rEl != null && rWr != null) {
          final rtaAngle = angle(rSh!, rEl!, rWr!);
          final ltaAngle = angle(lSh!,lEl!,lWr!);
          final rconAngle = angle(rEl!,rSh!,rHip!);
          final lconAngle = angle(lEl!,lSh!,lHip!);

          final rta = isShoulderPress(rtaAngle,ltaAngle,rconAngle,lconAngle,press.state);
          print("RTA ANGLE-> ${rtaAngle.toStringAsFixed(2)}");
          print("rta ${rta.toString()}");
          if (rta != null ) {
            if (rta == ShoulderPressState.init) {
              count++;
              print("Counter $count");
              //_speakCounter(count);



              press.setUpShoulderPressState(ShoulderPressState.init);
            } else if (rta == ShoulderPressState.complete) {

              count = 0;
              _speakCounter(press.counter);




              press.increment();
              press.setUpShoulderPressState(ShoulderPressState.neutral);
               _handleWorkoutLogic(
              exerciseLabel: widget.exerciseLabel,
              exerciseBloc: press,
               // This should be your method to stop pose/camera
              );
            } else {}
          }else
            {

            }
        }
      }else if(widget.exerciseLabel == 'Biceps Curl')
        {
          final bic = BlocProvider.of<BicepsCurlCounter>(context);


          for (final pose in widget.posePainter!.poses) {
            PoseLandmark getPoseLandmark(PoseLandmarkType type1) {
              final PoseLandmark? joint1 = pose.landmarks[type1];
              return joint1!;
            }

            rSh = getPoseLandmark(PoseLandmarkType.rightShoulder);
            rEl = getPoseLandmark(PoseLandmarkType.rightElbow);
            rWr = getPoseLandmark(PoseLandmarkType.rightWrist);
            rHip = getPoseLandmark(PoseLandmarkType.rightHip);
            rKnee = getPoseLandmark(PoseLandmarkType.rightKnee);

            lSh = getPoseLandmark(PoseLandmarkType.leftShoulder);
            lEl  = getPoseLandmark(PoseLandmarkType.leftElbow);
            lWr  = getPoseLandmark(PoseLandmarkType.leftWrist);
            lHip = getPoseLandmark(PoseLandmarkType.leftHip);
            lKnee = getPoseLandmark(PoseLandmarkType.leftKnee);
          }

          //verfication
          if (rSh != null && rEl != null && rWr != null) {
            final rtaAngle = angle(rSh!, rEl!, rWr!);
            final ltaAngle = angle(lSh!,lEl!,lWr!);
            final rHipAngle = angle(rSh!,rHip!,rKnee!);
            final lHipAngle = angle(lSh!,lHip!,lKnee!);

            final rta = isBicepsCurl(rtaAngle,ltaAngle,rHipAngle,lHipAngle, bic.state);
            print("RTA ANGLE-> ${rtaAngle.toStringAsFixed(2)}");
            print("rta ${rta.toString()}");
            if (rta != null) {
              if (rta == BicepsCurlState.init) {
                count++;
                print("Counter $count");

                if (count > 50) {
                  // showDialog(
                  //     context: context,
                  //     builder: (ctxt) => new AlertDialog(
                  //       title: Text("Text Dialog"),
                  //     )
                  // );
                  //
                  print("BicepsCurl Stopped");
                  //  Navigator.pop(context);
                  return;
                }
                bic.setUpBicepsCurlState(BicepsCurlState.init);
              } else if (rta == BicepsCurlState.complete) {
                count = 0;
                _speakCounter(bic.counter);

                bic.increment();
                bic.setUpBicepsCurlState(BicepsCurlState.neutral);

                 _handleWorkoutLogic(
                exerciseLabel: widget.exerciseLabel,
                exerciseBloc: bic,
                 // This should be your method to stop pose/camera
                );
              } else {}
            }
          }
        }else if(widget.exerciseLabel == 'Lateral Raises')
      {
        final lat = BlocProvider.of<LatraiseCounter>(context);


        for (final pose in widget.posePainter!.poses) {
          PoseLandmark getPoseLandmark(PoseLandmarkType type1) {
            final PoseLandmark? joint1 = pose.landmarks[type1];
            return joint1!;
          }

          rSh = getPoseLandmark(PoseLandmarkType.rightShoulder);
          rEl = getPoseLandmark(PoseLandmarkType.rightElbow);
          rWr = getPoseLandmark(PoseLandmarkType.rightWrist);
          rHip = getPoseLandmark(PoseLandmarkType.rightHip);

          lSh = getPoseLandmark(PoseLandmarkType.leftShoulder);
          lEl  = getPoseLandmark(PoseLandmarkType.leftElbow);
          lWr  = getPoseLandmark(PoseLandmarkType.leftWrist);
          lHip = getPoseLandmark(PoseLandmarkType.leftHip);
        }

        //verfication
        if (rSh != null && rEl != null && rWr != null && rHip != null) {
          final rtaAngle = angle(rEl!, rSh!, rHip!);
          final ltaAngle = angle(lEl!,lSh!,lHip!);

          var rta = isLatraise(rtaAngle,ltaAngle, lat.state);
          print("RTA ANGLE-> ${rtaAngle.toStringAsFixed(2)}");
          print("rta ${rta.toString()}");
          if (rta != null) {
            if (rta == LatraiseState.init) {
              _hasWarnedTooHigh=false;
              count++;
              print("Counter $count");

              if (count > 50) {
                // showDialog(
                //     context: context,
                //     builder: (ctxt) => new AlertDialog(
                //       title: Text("Text Dialog"),
                //     )
                // );
                //
                print("Latraise Stopped");
                //  Navigator.pop(context);
                return;
              }
              lat.setUpLatraiseState(LatraiseState.init);
            } else if (rta == LatraiseState.complete) {
              _hasWarnedTooHigh=false;
              count = 0;
              _speakCounter(lat.counter);

              lat.increment();
              lat.setUpLatraiseState(LatraiseState.neutral);

              _handleWorkoutLogic(
                exerciseLabel: widget.exerciseLabel,
                exerciseBloc: lat,
                // This should be your method to stop pose/camera
              );
            }else if(rta == LatraiseState.tooHigh)
              {
                //lat.decrement();
                rta=LatraiseState.init;
                if(!_hasWarnedTooHigh){
                  _hasWarnedTooHigh=true;
                  _postureCorrection(1);}
              }else {
              _hasWarnedTooHigh=false;
            }
          }
        }
      }else if(widget.exerciseLabel == 'Squats')
      {
        final sq = BlocProvider.of<SquatCounter>(context);


        for (final pose in widget.posePainter!.poses) {
          PoseLandmark getPoseLandmark(PoseLandmarkType type1) {
            final PoseLandmark? joint1 = pose.landmarks[type1];
            return joint1!;
          }

          rHip = getPoseLandmark(PoseLandmarkType.rightHip);
          rKnee = getPoseLandmark(PoseLandmarkType.rightKnee);
          rAnkle = getPoseLandmark(PoseLandmarkType.rightAnkle);
          lHip = getPoseLandmark(PoseLandmarkType.leftHip);
          lKnee = getPoseLandmark(PoseLandmarkType.leftKnee);
          lAnkle= getPoseLandmark(PoseLandmarkType.leftAnkle);

        }

        //verfication
        if (rHip != null && rKnee != null && rAnkle != null) {
          final rtaAngle = angle(rHip!, rKnee!, rAnkle!);

          final rta = isSquat(rtaAngle, sq.state);
          print("RTA ANGLE-> ${rtaAngle.toStringAsFixed(2)}");
          print("rta ${rta.toString()}");
          if (rta != null) {
            if (rta == SquatState.init) {
              count++;
              print("Counter $count");

              if (count > 50) {
                // showDialog(
                //     context: context,
                //     builder: (ctxt) => new AlertDialog(
                //       title: Text("Text Dialog"),
                //     )
                // );
                //
                print("Squat Stopped");
                //  Navigator.pop(context);
                return;
              }
              sq.setUpSquatState(SquatState.init);
            } else if (rta == SquatState.complete) {
              count = 0;
              _speakCounter(sq.counter);

              sq.increment();
              sq.setUpSquatState(SquatState.neutral);

              _handleWorkoutLogic(
                exerciseLabel: widget.exerciseLabel,
                exerciseBloc: sq,
                // This should be your method to stop pose/camera
              );
            } else {}
          }
        }
      }else if(widget.exerciseLabel == 'Triceps Extension')
      {
        final row = BlocProvider.of<TriExtCounter>(context);


        for (final pose in widget.posePainter!.poses) {
          PoseLandmark getPoseLandmark(PoseLandmarkType type1) {
            final PoseLandmark? joint1 = pose.landmarks[type1];
            return joint1!;
          }

          rSh = getPoseLandmark(PoseLandmarkType.rightShoulder);
          rEl = getPoseLandmark(PoseLandmarkType.rightElbow);
          rWr = getPoseLandmark(PoseLandmarkType.rightWrist);
          rHip = getPoseLandmark(PoseLandmarkType.rightHip);

          lSh = getPoseLandmark(PoseLandmarkType.leftShoulder);
          lEl = getPoseLandmark(PoseLandmarkType.leftElbow);
          lWr = getPoseLandmark(PoseLandmarkType.leftWrist);
          lHip = getPoseLandmark(PoseLandmarkType.leftHip);
        }

        //verfication
        if (rSh != null && rEl != null && rWr != null) {
          final rtaAngle = angle(rSh!, rEl!, rWr!);
          final ltaAngle = angle(lSh!,lEl!,lWr!);
          final lconAngle = angle(lEl!,lSh!,lHip!);
          final rconAngle = angle(rEl!,rSh!,rHip!);


          final rta = isTriExt(rtaAngle,ltaAngle,rconAngle,lconAngle, row.state);
          print("RTA ANGLE-> ${rtaAngle.toStringAsFixed(2)}");
          print("rta ${rta.toString()}");
          if (rta != null) {
            if (rta == TricExtState.init) {
              count++;
              print("Counter $count");

              if (count > 50) {
                // showDialog(
                //     context: context,
                //     builder: (ctxt) => new AlertDialog(
                //       title: Text("Text Dialog"),
                //     )
                // );
                //
                print("Row Stopped");
                //  Navigator.pop(context);
                return;
              }
              row.setUpRowState(TricExtState.init);
            } else if (rta == TricExtState.complete) {
              count = 0;
              _speakCounter(row.counter);

              row.increment();
              row.setUpRowState(TricExtState.neutral);

              _handleWorkoutLogic(
                exerciseLabel: widget.exerciseLabel,
                exerciseBloc: row,
                // This should be your method to stop pose/camera
              );
            } else {}
          }
        }
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _liveFeedBody());
  }

  Widget _liveFeedBody() {
    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: _changingCameraLens
                ? Center(
              child: const Text('Changing camera lens'),
            )
                : CameraPreview(
              _controller!,
              child: widget.customPaint,
            ),
          ),
          _counterWidget(widget.exerciseLabel),
          _backButton(),
          _switchLiveCameraToggle(),
         // _detectionViewModeToggle(),
          //_zoomControl(),
          //_exposureControl(),
        ],
      ),
    );
  }

  Widget _counterWidget(String exerciseLabel) {
    final counters = {
      'Shoulder Press': BlocProvider.of<ShoulderPressCounter>(context).counter,
      'Biceps Curl': BlocProvider.of<BicepsCurlCounter>(context).counter,
      'Lateral Raises': BlocProvider.of<LatraiseCounter>(context).counter,
      'Squats': BlocProvider.of<SquatCounter>(context).counter,
      'Triceps Extension': BlocProvider.of<TriExtCounter>(context).counter,
      // Add more...
    };

    final exerciseVideos = {
      'Shoulder Press': {
        'path': 'assets/videos/shoulderpress.mp4',
        'instructions': 'Press straight up without locking elbows. Keep back straight.',
      },
      'Biceps Curl': {
        'path': 'assets/videos/bicurl.mp4',
        'instructions': 'Curl slowly. Elbows close to body. No swinging.',
      },
      'Lateral Raises': {
        'path': 'assets/videos/latraises.mp4',
        'instructions': 'Raise arms to shoulder level. Slight bend in elbows. Don’t shrug.',
      },
      'Triceps Extension': {
        'path': 'assets/videos/triext.mp4',
        'instructions': 'Keep elbows stationary. Extend fully and lower with control.',
      },
      'Squats': {
        'path': 'assets/videos/squats.mp4',
        'instructions': 'Keep back straight. Knees behind toes. Go to parallel or lower.',
      },
    };


    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () {
          final videoData = exerciseVideos[exerciseLabel];
          if (videoData != null) {
            showWorkoutVideoModal(
              context: context,
              videoAssetPath: videoData['path']!,
              instructions: videoData['instructions']!,
            );
          } else {
            print("No video found for: $exerciseLabel");
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: Colors.grey.withOpacity(0.3),
                width: 2.0,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseLabel,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${counters[exerciseLabel] ?? 0}/15",
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.fitness_center,
                size: 40,
                color: Colors.blueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }




  Widget _backButton() => Positioned(
    top: 40,
    left: 8,
    child: SizedBox(
      height: 50.0,
      width: 50.0,
      child: FloatingActionButton(
        heroTag: Object(),
        onPressed: () {
          BlocProvider.of<ShoulderPressCounter>(context).reset();
          BlocProvider.of<BicepsCurlCounter>(context).reset();
          BlocProvider.of<LatraiseCounter>(context).reset();
          BlocProvider.of<SquatCounter>(context).reset();
          BlocProvider.of<TriExtCounter>(context).reset();
          Navigator.of(context).pop();
        },
        backgroundColor: Colors.black54,
        child: Icon(
          Icons.arrow_back_ios_outlined,
          size: 20,
        ),
      ),
    ),
  );

 /* Widget _detectionViewModeToggle() => Positioned(
    bottom: 8,
    left: 8,
    child: SizedBox(
      height: 50.0,
      width: 50.0,
      child: FloatingActionButton(
        heroTag: Object(),
        onPressed: widget.onDetectorViewModeChanged,
        backgroundColor: Colors.black54,
        child: Icon(
          Icons.photo_library_outlined,
          size: 25,
        ),
      ),
    ),
  );
  */


  Widget _switchLiveCameraToggle() => Positioned(
    top: 40,
    right: 8,
    child: SizedBox(
      height: 50.0,
      width: 50.0,
      child: FloatingActionButton(
        heroTag: Object(),
        onPressed: _switchLiveCamera,
        backgroundColor: Colors.black54,
        child: Icon(
          Platform.isIOS
              ? Icons.flip_camera_ios_outlined
              : Icons.flip_camera_android_outlined,
          size: 25,
        ),
      ),
    ),
  );

  /*Widget _zoomControl() => Positioned(
    bottom: 16,
    left: 0,
    right: 0,
    child: Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: 250,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Slider(
                value: _currentZoomLevel,
                min: _minAvailableZoom,
                max: _maxAvailableZoom,
                activeColor: Colors.white,
                inactiveColor: Colors.white30,
                onChanged: (value) async {
                  setState(() {
                    _currentZoomLevel = value;
                  });
                  await _controller?.setZoomLevel(value);
                },
              ),
            ),
            Container(
              width: 50,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    '${_currentZoomLevel.toStringAsFixed(1)}x',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

   */

  /*Widget _exposureControl() => Positioned(
    top: 40,
    right: 8,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 250,
      ),
      child: Column(children: [
        Container(
          width: 55,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '${_currentExposureOffset.toStringAsFixed(1)}x',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SizedBox(
              height: 30,
              child: Slider(
                value: _currentExposureOffset,
                min: _minAvailableExposureOffset,
                max: _maxAvailableExposureOffset,
                activeColor: Colors.white,
                inactiveColor: Colors.white30,
                onChanged: (value) async {
                  setState(() {
                    _currentExposureOffset = value;
                  });
                  await _controller?.setExposureOffset(value);
                },
              ),
            ),
          ),
        )
      ]),
    ),
  );

   */

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      // Set to ResolutionPreset.high. Do NOT set it to ResolutionPreset.max because for some phones does NOT work.
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
     /* _controller?.getMinZoomLevel().then((value) {
        _currentZoomLevel = value;
        _minAvailableZoom = value;
      });
      _controller?.getMaxZoomLevel().then((value) {
        _maxAvailableZoom = value;
      });
      _currentExposureOffset = 0.0;
      _controller?.getMinExposureOffset().then((value) {
        _minAvailableExposureOffset = value;
      });
      _controller?.getMaxExposureOffset().then((value) {
        _maxAvailableExposureOffset = value;
      });

      */
      _controller?.startImageStream(_processCameraImage).then((value) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
        if (widget.onCameraLensDirectionChanged != null) {
          widget.onCameraLensDirectionChanged!(camera.lensDirection);
        }
      });
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    widget.onImage(inputImage);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    // print(
    //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
      _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      // print('rotationCompensation: $rotationCompensation');
    }
    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
}

