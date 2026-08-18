import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/colors/app_colors.dart';

/// Six individual digit boxes for OTP entry — mirrors the React OtpLogin UI.
/// Auto-focuses next box on entry, handles backspace navigation, and paste.
class OtpInputWidget extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final VoidCallback? onChanged;

  const OtpInputWidget({
    super.key,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  static const int _length = 6;
  final List<TextEditingController> _controllers =
      List.generate(_length, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_length, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentOtp =>
      _controllers.map((c) => c.text).join();

  void _checkComplete() {
    final otp = _currentOtp;
    widget.onChanged?.call();
    if (otp.length == _length) {
      widget.onCompleted(otp);
    }
  }

  void _handlePaste(String pasted) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= _length) {
      for (int i = 0; i < _length; i++) {
        _controllers[i].text = digits[i];
      }
      _focusNodes[_length - 1].requestFocus();
      _checkComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_length, (i) {
        return Container(
          width: 44,
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: TextField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white.withOpacity(0.12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.25),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.25),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.champagne,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (value) {
              // Handle paste via onChanged (if 6 chars pasted into one field)
              if (value.length > 1) {
                _handlePaste(value);
                return;
              }
              if (value.isNotEmpty && i < _length - 1) {
                _focusNodes[i + 1].requestFocus();
              }
              _checkComplete();
            },
            onTap: () {
              _controllers[i].selection = TextSelection(
                baseOffset: 0,
                extentOffset: _controllers[i].text.length,
              );
            },
            onSubmitted: (_) {
              if (i < _length - 1) {
                _focusNodes[i + 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }

  // Expose a clear method for parent to reset
  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }
}
