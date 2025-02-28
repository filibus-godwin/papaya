import 'package:flutter/material.dart';
import 'package:papaya/player/player.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold(body: Center(child: HomePage())));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: buttonOnPressed,
      child: const Text('Start Video'),
    );
  }

  void buttonOnPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VideoPlayerPage()),
    );
  }
}

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final playerKey = GlobalKey<Player360WidgetState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final height =
        (playerKey.currentState?.playerState.isFullscreen ?? false)
            ? MediaQuery.of(context).size.height
            : size.width / 2;
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        return Scaffold(
          appBar: isLandscape ? null : AppBar(),
          body: Player360Widget(
            width: size.width,
            height: height,
            videoUrl:
                'https://codetricity.github.io/flutter_video_display/ageda.MP4',
          ),
        );
      },
    );
  }
}
