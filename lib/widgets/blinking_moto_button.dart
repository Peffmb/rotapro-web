import 'package:flutter/material.dart';

class BlinkingMotoButton extends StatefulWidget {
  final bool isSimulating;
  final VoidCallback onPressed;

  const BlinkingMotoButton({
    super.key,
    required this.isSimulating,
    required this.onPressed,
  });

  @override
  State<BlinkingMotoButton> createState() => _BlinkingMotoButtonState();
}

class _BlinkingMotoButtonState extends State<BlinkingMotoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isSimulating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant BlinkingMotoButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSimulating != oldWidget.isSimulating) {
      if (widget.isSimulating) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 1.0; // Reset to full opacity
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return IconButton(
          onPressed: widget.onPressed,
          icon: Icon(
            Icons.two_wheeler,
            color: widget.isSimulating
                ? Colors.green.withOpacity(_opacityAnimation.value)
                : Colors.white, // Apagado/Inativo (Branco do AppBar)
             size: 28,
          ),
          tooltip: widget.isSimulating ? "Parar Simulação" : "Iniciar Simulação",
        );
      },
    );
  }
}
