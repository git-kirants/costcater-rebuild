import 'package:flutter/material.dart';

enum ToastType { success, error, info }

class Toast extends StatelessWidget {
  final String message;
  final ToastType type;
  final VoidCallback? onClose;

  const Toast({
    super.key,
    required this.message,
    this.type = ToastType.success,
    this.onClose,
  });

  Color get backgroundColor {
    switch (type) {
      case ToastType.success:
        return const Color(0xFFEBFDF2); // Lighter green background
      case ToastType.error:
        return const Color(0xFFFDF2F2); // Lighter red background
      case ToastType.info:
        return const Color(0xFFF0F7FF); // Lighter blue background
    }
  }

  Color get borderColor {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF52ed28);
      case ToastType.error:
        return const Color(0xFFE53535);
      case ToastType.info:
        return const Color(0xFF3B82F6);
    }
  }

  Color get iconColor {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF16A34A); // Darker green for better contrast
      case ToastType.error:
        return const Color(0xFFDC2626); // Darker red for better contrast
      case ToastType.info:
        return const Color(0xFF2563EB); // Darker blue for better contrast
    }
  }

  IconData get icon {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      constraints: const BoxConstraints(maxWidth: 400), // Limit max width
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.8),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: onClose,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ToastService {
  static final ToastService _instance = ToastService._internal();
  factory ToastService() => _instance;
  ToastService._internal();

  OverlayEntry? _currentToast;

  void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    _currentToast?.remove();

    final overlay = Overlay.of(context);
    _currentToast = OverlayEntry(
      builder: (context) => SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Align(
            alignment: const Alignment(0, 0.9),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: 1.0,
              child: Toast(
                message: message,
                type: type,
                onClose: () => _currentToast?.remove(),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_currentToast!);

    Future.delayed(duration, () {
      if (_currentToast?.mounted ?? false) {
        _currentToast?.remove();
        _currentToast = null;
      }
    });
  }

  void hide() {
    _currentToast?.remove();
    _currentToast = null;
  }
}

// Extension method for easier access
extension ToastExtension on BuildContext {
  void showToast(
    String message, {
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    ToastService().show(
      this,
      message: message,
      type: type,
      duration: duration,
    );
  }

  void hideToast() {
    ToastService().hide();
  }
}
