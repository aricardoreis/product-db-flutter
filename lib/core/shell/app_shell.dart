import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _go(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/scan'),
        tooltip: 'Scan invoice',
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        height: 64,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Expanded(
              child: _NavButton(
                icon: Icons.receipt_long,
                label: 'Sales',
                selected: currentIndex == 0,
                color: colors,
                onTap: () => _go(0),
              ),
            ),
            const SizedBox(width: 56),
            Expanded(
              child: _NavButton(
                icon: Icons.inventory_2_outlined,
                label: 'Products',
                selected: currentIndex == 1,
                color: colors,
                onTap: () => _go(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final ColorScheme color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = selected ? color.primary : color.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: tint, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: tint, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
