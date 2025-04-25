import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:fitquest/models/bicurl.dart';

import '../models/latraise.dart';
import '../models/triext.dart';
import '../models/shpress.dart';
import '../models/squat.dart';
import 'painters/pose_painter.dart';

import 'camera_view.dart';

class PoseDetectorView extends StatefulWidget {
  final String exerciseLabel;
  //final Function()? onCameraFeedReady;

  const PoseDetectorView({
    Key? key,
    required this.exerciseLabel,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseDetector _poseDetector =
  PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;
  PosePainter? posePainter;

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide different BLoCs depending on exerciseLabel

          BlocProvider(create: (context) => ShoulderPressCounter()),

          BlocProvider(create: (context) => BicepsCurlCounter()),

          BlocProvider(create: (context) => LatraiseCounter()),

          BlocProvider(create: (context) => SquatCounter()),

          BlocProvider(create: (context) => TriExtCounter()),
       // A default BLoC if necessary
      ],
      child:Scaffold(
         // appBar: AppBar(title: Text(widget.exerciseLabel),),
          body:
          CameraView(
        posePainter: posePainter,
        customPaint: _customPaint,
        onImage: _processImage,
        //onCameraFeedReady: onCameraFeedReady,
        //onDetectorViewModeChanged: _onDetectorViewModeChanged,
        initialCameraLensDirection: _cameraLensDirection,
        onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        exerciseLabel: widget.exerciseLabel,
      ))
     );

  }





  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final poses = await _poseDetector.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
      posePainter = painter;
    } else {
      _text = 'Poses found: ${poses.length}\n\n';
      // TODO: set _customPaint to draw landmarks on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}