part of 'player.dart';

class PlayerControls extends StatefulWidget {
  const PlayerControls({super.key, required this.playerContext});

  final ListenablePlayerContext playerContext;

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  @override
  Widget build(BuildContext context) {
    final playerContext = widget.playerContext;
    return ColoredBox(
      color: Colors.black,
      child: Row(
        children: <Widget>[
          _PlayAndPauseButton(playerContext: playerContext),
          Text(
            playerContext.currentPosition,
            style: const TextStyle(color: Colors.white),
          ),
          Expanded(child: _Slider(playerContext: playerContext)),
          Text(
            playerContext.duration,
            style: const TextStyle(color: Colors.white),
          ),
          _VolumeButton(playerContext: playerContext),
          _FullscreenButton(playerContext: playerContext),
          _Cardboard(playerContext: playerContext),
        ],
      ),
    );
  }
}

class _PlayAndPauseButton extends StatelessWidget {
  const _PlayAndPauseButton({required this.playerContext});
  final ListenablePlayerContext playerContext;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        playerContext.isVideoFinished
            ? Icons.replay
            : playerContext.isPlaying
            ? Icons.pause
            : Icons.play_arrow,
        color: Colors.white,
      ),
      onPressed: playAndPause,
    );
  }

  Future<void> playAndPause() async {
    if (playerContext.isVideoFinished) {
      await playerContext.controller?.seekTo(0);
    }

    if (playerContext.isPlaying) {
      await playerContext.controller?.pause();
    } else {
      await playerContext.controller?.play();
    }

    playerContext.updateWith(
      isPlaying: !playerContext.isPlaying,
      isVideoFinished: false,
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider({required this.playerContext});

  final ListenablePlayerContext playerContext;

  @override
  Widget build(BuildContext context) {
    final controller = playerContext.controller;
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
        value: playerContext.seekPosition,
        max: playerContext.intDuration.toDouble(),
        onChangeEnd: (value) => controller?.seekTo(value.toInt()),
        onChanged: (value) => onChangePosition(value.toInt()),
      ),
    );
  }

  void onChangePosition(int millis) {
    playerContext.updateWith(
      currentPosition: millis.toMsDuration.toPlayerDurationText,
      seekPosition: millis.toDouble(),
    );
  }
}

class _VolumeButton extends StatelessWidget {
  const _VolumeButton({required this.playerContext});

  final ListenablePlayerContext playerContext;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        if (!playerContext.isFullscreen || !isLandscape) {
          return SizedBox();
        }

        return IconButton(
          icon: Icon(
            playerContext.isVolumeEnabled
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
    playerContext.updateWith(isVolumeSliderShown: show);
  }
}

class _FullscreenButton extends StatelessWidget {
  const _FullscreenButton({required this.playerContext});

  final ListenablePlayerContext playerContext;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        playerContext.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
        color: Colors.white,
      ),
      onPressed: fullScreenPressed,
    );
  }

  Future<void> fullScreenPressed() async {
    await playerContext.controller?.fullScreen();
    playerContext.updateWith(isFullscreen: playerContext.isFullscreen);

    if (playerContext.isFullscreen) {
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
  const _Cardboard({required this.playerContext});
  final ListenablePlayerContext playerContext;

  void cardBoardPressed() {
    playerContext.controller?.toggleVRMode();
  }

  @override
  Widget build(BuildContext context) {
    if (!playerContext.isFullscreen) return Offstage();
    return IconButton(icon: Icon(Icons.bolt), onPressed: cardBoardPressed);
  }
}
