import 'package:flutter/material.dart';

class BookingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const BookingButton({
    super.key,
    this.onPressed,
    this.text = 'Записаться',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}