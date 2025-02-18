import 'package:flutter/material.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isVariant;
  final IconData? icon;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isVariant = false,
    this.icon,
  }) : super(key: key);

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> get _defaultGradient => [
    const Color(0xFF000000),
    const Color(0xFF08012C),
    const Color(0xFF4E1E40),
    const Color(0xFF70464E),
    const Color(0xFF88394C),
  ];

  List<Color> get _hoverGradient => [
    const Color(0xFFC96287),
    const Color(0xFFC66C64),
    const Color(0xFFCC7D23),
    const Color(0xFF37140A),
    const Color(0xFF000000),
  ];

  List<Color> get _variantGradient => [
    const Color(0xFF000022),
    const Color(0xFF1F3F6D),
    const Color(0xFF469396),
    const Color(0xFFF1FFA5),
  ];

  List<Color> get _variantHoverGradient => [
    const Color(0xFF000020),
    const Color(0xFFF1FFA5),
    const Color(0xFF469396),
    const Color(0xFF1F3F6D),
    const Color(0xFF000000),
  ];

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isHovered
                  ? (widget.isVariant ? _variantHoverGradient : _hoverGradient)
                  : (widget.isVariant ? _variantGradient : _defaultGradient),
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.isVariant ? _variantGradient : _defaultGradient).first.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(11),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: Colors.white),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
