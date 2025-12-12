import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavigationTabItem(
            icon: Icons.chat_outlined,
            activeIcon: Icons.chat,
            label: 'Chats',
            isSelected: currentIndex == 0,
            onTap: () => onTabSelected(0),
          ),
          _NavigationTabItem(
            icon: Icons.call_outlined,
            activeIcon: Icons.call,
            label: 'Llamadas',
            isSelected: currentIndex == 1,
            onTap: () => onTabSelected(1),
          ),
          _NavigationTabItem(
            icon: Icons.group_outlined,
            activeIcon: Icons.group,
            label: 'Contactos',
            isSelected: currentIndex == 2,
            onTap: () => onTabSelected(2),
          ),
          _NavigationTabItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Perfil',
            isSelected: currentIndex == 3,
            onTap: () => onTabSelected(3),
          ),
        ],
      ),
    );
  }
}

class _NavigationTabItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavigationTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavigationTabItem> createState() => _NavigationTabItemState();
}

class _NavigationTabItemState extends State<_NavigationTabItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isSelected ? widget.activeIcon : widget.icon,
                color:
                    widget.isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withAlpha(200),
                size: 22,
              ),
              Text(
                widget.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      widget.isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withAlpha(200),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
