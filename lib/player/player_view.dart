part of 'player.dart';

// 'https://cdn.bitmovin.com/content/assets/playhouse-vr/m3u8s/105560.m3u8'

class Player360View extends StatelessWidget {
  const Player360View({
    super.key,
    required this.videoUrl,
    required this.playerState,
  });

  final String videoUrl;
  final ListenablePlayerState playerState;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final height =
        playerState.isFullscreen
            ? MediaQuery.of(context).size.height
            : size.width / 2;
    return VrPlayer(
      key: ValueKey(videoUrl),
      x: 0,
      y: 0,
      width: size.width,
      height: height,
      onCreated: onViewPlayerCreated,
    );
  }

  void onViewPlayerCreated(
    VrPlayerController controller,
    VrPlayerObserver observer,
  ) {
    playerState
      ..reset()
      ..updateWith(controller: controller);
    observer
      ..onStateChange = onReceiveState
      ..onDurationChange = onReceiveDuration
      ..onPositionChange = onChangePosition
      ..onFinishedChange = onReceiveEnded;
    playerState.controller?.loadVideo(videoUrl: videoUrl);
  }

  void onReceiveState(VrState state) {
    log(state.name);
    switch (state) {
      case VrState.loading:
        playerState.updateWith(isVideoLoading: true);
        break;
      case VrState.ready:
        playerState.updateWith(isVideoLoading: false, isVideoReady: true);
        break;
      case VrState.buffering:
      case VrState.idle:
        break;
    }
  }

  void onReceiveDuration(int millis) {
    playerState.updateWith(
      intDuration: millis,
      duration: millis.toMsDuration.toPlayerDurationText,
    );
  }

  void onChangePosition(int millis) {
    playerState.updateWith(
      currentPosition: millis.toMsDuration.toPlayerDurationText,
      seekPosition: millis.toDouble(),
    );
  }

  void onReceiveEnded(bool isFinished) {
    playerState.updateWith(isVideoFinished: isFinished);
  }

  void onChangeVolumeSlider(double value) {
    playerState.controller?.setVolume(value);
    playerState.updateWith(
      currentSliderValue: value,
      isVolumeEnabled: value != 0,
    );
  }

  void switchVolumeSliderDisplay({required bool show}) {
    playerState.updateWith(isVolumeSliderShown: show);
  }
}

extension _IntExtension on int {
  Duration get toMsDuration => Duration(milliseconds: this);
}

extension _DurationExtension on Duration {
  String get toPlayerDurationText {
    String twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }

    final twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(inSeconds.remainder(60));
    return '${twoDigits(inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }
}
