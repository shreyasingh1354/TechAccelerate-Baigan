import 'package:flutter/material.dart';

class SosButton extends StatefulWidget {
  const SosButton({Key? key, required this.onPressed}) : super(key: key);

  final Future<bool> Function() onPressed;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> {
  bool _isSending = false;
  bool _isSent = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        clipBehavior: Clip.antiAlias,
        style: ElevatedButton.styleFrom(
          overlayColor: _isSent ? Colors.grey : Colors.red,
          backgroundColor: _isSent
              ? Colors.grey.withOpacity(0.4)
              : (_isSending
                  ? Colors.orange.withOpacity(0.4)
                  : Colors.red.withOpacity(0.4)),
          fixedSize: const Size(100, 100),
          shape: const CircleBorder(),
          elevation: 18,
          shadowColor:
              _isSent ? Colors.grey : (_isSending ? Colors.orange : Colors.red),
          padding: EdgeInsets.zero,
        ),
        onPressed: _isSent
            ? null
            : () async {
                if (!_isSending) {
                  setState(() {
                    _isSending = true;
                  });

                  try {
                    bool success = await widget.onPressed();
                    setState(() {
                      _isSending = false;
                      if (success) {
                        _isSent = true;
                      }
                    });
                  } catch (e) {
                    setState(() {
                      _isSending = false;
                    });
                  }
                }
              },
        child: _isSending
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : Text(
                _isSent ? 'SENT' : 'SOS',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
