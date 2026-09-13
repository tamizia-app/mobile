import 'package:flutter/material.dart';

class SelectableWordCard extends StatelessWidget {
  const SelectableWordCard({
    required this.text,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFFF640A),
          borderRadius: BorderRadius.circular(24),
          border: selected
              ? Border.all(color: const Color(0xFFB8E4FA), width: 4)
              : null,
          boxShadow: const [
            BoxShadow(color: Color(0xFFE94C00), offset: Offset(0, 6)),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
