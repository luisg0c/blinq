import 'package:flutter/material.dart';

/// Botão customizado com loading state, cor primária e cantos arredondados.
class CustomButton extends StatelessWidget {
  /// Texto exibido no botão.
  final String label;

  /// Callback executado ao pressionar o botão.
  final VoidCallback? onPressed;

  /// Indica se deve exibir um loading spinner.
  final bool isLoading;

  /// Se deve tornar o botão expanded (preenche largura disponível).
  final bool fullWidth;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6EE1C6);
    final textColor = Colors.white;

    Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(textColor),
            ),
          )
        : Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          );

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        primary: primaryColor,
        onPrimary: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
      child: child,
    );

    return fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
