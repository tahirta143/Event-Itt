import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoBgWidget extends StatefulWidget {
  final Widget child;
  final String? videoUrl;

  const VideoBgWidget({
    super.key,
    required this.child,
    this.videoUrl,
  });

  @override
  State<VideoBgWidget> createState() => _VideoBgWidgetState();
}

class _VideoBgWidgetState extends State<VideoBgWidget> with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  late AnimationController _animationController;
  bool _isVideoInitialized = false;

  // Default luxury wedding background video asset
  static const String _defaultVideoUrl = 'assets/videos/onboard.mp4';


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _initVideo();
  }

  void _initVideo() {
    final url = widget.videoUrl ?? _defaultVideoUrl;
    try {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      } else {
        _videoController = VideoPlayerController.asset(url);
      }

      _videoController?.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          _videoController?.setLooping(true);
          _videoController?.setVolume(0.0);
          _videoController?.play();
        }
      }).catchError((error) {
        debugPrint('Video Player initialization error: $error');
        if (mounted) {
          setState(() {
            _isVideoInitialized = false;
          });
        }
      });
    } catch (e) {
      debugPrint('Video Controller creation error: $e');
    }
  }


  @override
  void dispose() {
    _videoController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Stack(
        children: [
          // Background Video or Animated Fallback Image
          Positioned.fill(
            child: _isVideoInitialized && _videoController != null
                ? FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                : AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_animationController.value * 0.08),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&q=80&w=1200',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),

          // Dark Luxury Overlay Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),

          // Ambient Gold Glow Effect
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.15 + (_animationController.value * 0.1),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.8,
                        colors: [
                          Color(0xFFD4AF37),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Foreground Content
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}


