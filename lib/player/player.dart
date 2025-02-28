import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vr_player/vr_player.dart';

part 'controls.dart';
part 'player_view.dart';

class _PlayerState {
  _PlayerState({
    this.duration = '99:99',
    this.intDuration = 0,
    this.seekPosition = 0.0,
    this.currentPosition = '00:00',
    this.isFullscreen = false,
    this.isVideoReady = false,
    this.isVideoLoading = true,
    this.isPlaying = false,
    this.isVideoFinished = false,
    this.isVolumeEnabled = true,
    this.currentSliderValue = 0.0,
    this.isVolumeSliderShown = false,
    this.controller,
  });

  final int intDuration;
  final String duration;
  final bool isVideoReady;
  final bool isPlaying;
  final bool isFullscreen;
  final bool isVolumeEnabled;
  final bool isVideoFinished;
  final bool isVideoLoading;
  final double seekPosition;
  final String currentPosition;
  final double currentSliderValue;
  final bool isVolumeSliderShown;
  final VrPlayerController? controller;

  _PlayerState copyWith({
    int? intDuration,
    String? duration,
    bool? isVideoReady,
    bool? isFullscreen,
    bool? isPlaying,
    bool? isVideoFinished,
    bool? isVideoLoading,
    double? seekPosition,
    double? currentSliderValue,
    bool? isVolumeEnabled,
    String? currentPosition,
    bool? isVolumeSliderShown,
    VrPlayerController? controller,
  }) {
    return _PlayerState(
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      controller: controller ?? this.controller,
      intDuration: intDuration ?? this.intDuration,
      seekPosition: seekPosition ?? this.seekPosition,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      isVideoReady: isVideoReady ?? this.isVideoReady,
      isVideoLoading: isVideoLoading ?? this.isVideoLoading,
      isVolumeEnabled: isVolumeEnabled ?? this.isVolumeEnabled,
      isVideoFinished: isVideoFinished ?? this.isVideoFinished,
      currentPosition: currentPosition ?? this.currentPosition,
      currentSliderValue: currentSliderValue ?? this.currentSliderValue,
      isVolumeSliderShown: isVolumeSliderShown ?? this.isVolumeSliderShown,
    );
  }
}

class ListenablePlayerState extends ChangeNotifier {
  ListenablePlayerState();

  _PlayerState _context = _PlayerState();

  VrPlayerController? get controller => _context.controller;

  int get intDuration => _context.intDuration;
  String get duration => _context.duration;
  bool get isVideoReady => _context.isVideoReady;
  bool get isPlaying => _context.isPlaying;
  bool get isFullscreen => _context.isFullscreen;
  bool get isVolumeEnabled => _context.isVolumeEnabled;
  bool get isVideoFinished => _context.isVideoFinished;
  bool get isVideoLoading => _context.isVideoLoading;
  double get seekPosition => _context.seekPosition;
  String get currentPosition => _context.currentPosition;
  double get currentSliderValue => _context.currentSliderValue;
  bool get isVolumeSliderShown => _context.isVolumeSliderShown;

  void reset() {
    _context = _PlayerState();
    notifyListeners();
  }

  void updateWith({
    int? intDuration,
    String? duration,
    bool? isVideoReady,
    bool? isFullscreen,
    bool? isPlaying,
    bool? isVideoFinished,
    bool? isVideoLoading,
    double? seekPosition,
    double? currentSliderValue,
    bool? isVolumeEnabled,
    String? currentPosition,
    bool? isVolumeSliderShown,
    VrPlayerController? controller,
  }) {
    _context = _context.copyWith(
      duration: duration,
      isPlaying: isPlaying,
      controller: controller,
      intDuration: intDuration,
      seekPosition: seekPosition,
      isFullscreen: isFullscreen,
      isVideoReady: isVideoReady,
      isVideoLoading: isVideoLoading,
      isVolumeEnabled: isVolumeEnabled,
      isVideoFinished: isVideoFinished,
      currentPosition: currentPosition,
      currentSliderValue: currentSliderValue,
      isVolumeSliderShown: isVolumeSliderShown,
    );
    notifyListeners();
  }
}

class Player360Widget extends StatefulWidget {
  const Player360Widget({super.key, required this.videoUrl});
  final String videoUrl;

  @override
  State<Player360Widget> createState() => _Player360WidgetState();
}

class _Player360WidgetState extends State<Player360Widget> {
  final ListenablePlayerState playerState = ListenablePlayerState();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Player360View(videoUrl: widget.videoUrl, playerState: playerState),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ListenableBuilder(
            listenable: playerState,
            builder: (context, child) {
              return PlayerControls(playerState: playerState);
            },
          ),
        ),
        Positioned(
          height: 180,
          right: 4,
          top: MediaQuery.of(context).size.height / 4,
          child: VolumeSlider(playerState: playerState),
        ),

        Positioned.fill(
          child: ListenableBuilder(
            listenable: playerState,
            builder: (context, child) {
              if (!playerState.isVideoLoading) return SizedBox();
              return ColoredBox(
                color: Colors.black,
                child: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      ],
    );
  }
}

class VolumeSlider extends StatelessWidget {
  const VolumeSlider({super.key, required this.playerState});
  final ListenablePlayerState playerState;

  @override
  Widget build(BuildContext context) {
    if (!playerState.isVolumeSliderShown) return Offstage();
    return RotatedBox(
      quarterTurns: 3,
      child: Slider(
        value: playerState.currentSliderValue,
        divisions: 10,
        onChanged: onChangeVolumeSlider,
      ),
    );
  }

  void onChangeVolumeSlider(double value) {
    playerState.controller?.setVolume(value);
    playerState.updateWith(
      isVolumeEnabled: value != 0,
      currentSliderValue: value,
    );
  }
}
