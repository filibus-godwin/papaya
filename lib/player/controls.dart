part of 'player.dart';

class PlayerControls extends StatefulWidget {
  const PlayerControls({super.key, required this.playerState});

  final ListenablePlayerState playerState;

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  @override
  Widget build(BuildContext context) {
    final playerState = widget.playerState;
    return ColoredBox(
      color: Colors.black,
      child: Row(
        children: <Widget>[
          _PlayAndPauseButton(playerState: playerState),
          Text(
            playerState.currentPosition,
            style: const TextStyle(color: Colors.white),
          ),
          Expanded(child: _Slider(playerState: playerState)),
          Text(
            playerState.duration,
            style: const TextStyle(color: Colors.white),
          ),
          _VolumeButton(playerState: playerState),
          _FullscreenButton(playerState: playerState),
          _Cardboard(playerState: playerState),
        ],
      ),
    );
  }
}

class _PlayAndPauseButton extends StatelessWidget {
  const _PlayAndPauseButton({required this.playerState});
  final ListenablePlayerState playerState;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        playerState.isVideoFinished
            ? Icons.replay
            : playerState.isPlaying
            ? Icons.pause
            : Icons.play_arrow,
        color: Colors.white,
      ),
      onPressed: playAndPause,
    );
  }

  Future<void> playAndPause() async {
    if (playerState.isVideoFinished) {
      await playerState.controller?.seekTo(0);
    }

    if (playerState.isPlaying) {
      await playerState.controller?.pause();
    } else {
      await playerState.controller?.play();
    }

    playerState.updateWith(
      isPlaying: !playerState.isPlaying,
      isVideoFinished: false,
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider({required this.playerState});

  final ListenablePlayerState playerState;

  @override
  Widget build(BuildContext context) {
    final controller = playerState.controller;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.amberAccent,
        inactiveTrackColor: Colors.grey,
        trackHeight: 5,
        thumbColor: Colors.white,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayColor: Colors.purple.withAlpha(32),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      ),
      child: Slider(
        min: 0.0,
        value: playerState.seekPosition,
        max: playerState.intDuration.toDouble(),
        onChangeEnd: (value) => controller?.seekTo(value.toInt()),
        onChanged: (value) => onChangePosition(value.toInt()),
      ),
    );
  }

  void onChangePosition(int millis) {
    playerState.updateWith(
      currentPosition: millis.toMsDuration.toPlayerDurationText,
      seekPosition: millis.toDouble(),
    );
  }
}

class _VolumeButton extends StatelessWidget {
  const _VolumeButton({required this.playerState});

  final ListenablePlayerState playerState;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        if (!playerState.isFullscreen || !isLandscape) {
          return SizedBox();
        }

        return IconButton(
          icon: Icon(
            playerState.isVolumeEnabled
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            color: Colors.white,
          ),
          onPressed: () => switchVolumeSliderDisplay(show: true),
        );
      },
    );
  }

  void switchVolumeSliderDisplay({required bool show}) {
    playerState.updateWith(isVolumeSliderShown: show);
  }
}

class _FullscreenButton extends StatelessWidget {
  const _FullscreenButton({required this.playerState});

  final ListenablePlayerState playerState;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        playerState.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
        color: Colors.white,
      ),
      onPressed: fullScreenPressed,
    );
  }

  Future<void> fullScreenPressed() async {
    await playerState.controller?.fullScreen();
    playerState.updateWith(isFullscreen: playerState.isFullscreen);

    if (playerState.isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
  }
}

class _Cardboard extends StatelessWidget {
  const _Cardboard({required this.playerState});
  final ListenablePlayerState playerState;

  void cardBoardPressed() {
    playerState.controller?.toggleVRMode();
  }

  @override
  Widget build(BuildContext context) {
    if (!playerState.isFullscreen) return Offstage();
    return IconButton(icon: Icon(Icons.bolt), onPressed: cardBoardPressed);
  }
}
