part of 'player.dart';

// 'https://cdn.bitmovin.com/content/assets/playhouse-vr/m3u8s/105560.m3u8'

class Player360 extends StatelessWidget {
  const Player360({
    super.key,
    required this.videoUrl,
    required this.playerContext,
  });

  final String videoUrl;
  final ListenablePlayerContext playerContext;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final height =
        playerContext.isFullscreen
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
    playerContext
      ..reset()
      ..updateWith(controller: controller);
    observer
      ..onStateChange = onReceiveState
      ..onDurationChange = onReceiveDuration
      ..onPositionChange = onChangePosition
      ..onFinishedChange = onReceiveEnded;
    playerContext.controller?.loadVideo(videoUrl: videoUrl);
  }

  void onReceiveState(VrState state) {
    switch (state) {
      case VrState.loading:
        playerContext.updateWith(isVideoLoading: true);
        break;
      case VrState.ready:
        playerContext.updateWith(isVideoLoading: false, isVideoReady: true);
        break;
      case VrState.buffering:
      case VrState.idle:
        break;
    }
  }

  void onReceiveDuration(int millis) {
    playerContext.updateWith(
      intDuration: millis,
      duration: millis.toMsDuration.toPlayerDurationText,
    );
  }

  void onChangePosition(int millis) {
    playerContext.updateWith(
      currentPosition: millis.toMsDuration.toPlayerDurationText,
      seekPosition: millis.toDouble(),
    );
  }

  void onReceiveEnded(bool isFinished) {
    playerContext.updateWith(isVideoFinished: isFinished);
  }

  void onChangeVolumeSlider(double value) {
    playerContext.controller?.setVolume(value);
    playerContext.updateWith(
      currentSliderValue: value,
      isVolumeEnabled: value != 0,
    );
  }

  void switchVolumeSliderDisplay({required bool show}) {
    playerContext.updateWith(isVolumeSliderShown: show);
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
