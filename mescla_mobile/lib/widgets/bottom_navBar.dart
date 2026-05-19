// Autor: Alinne Monteiro de Melo
// RA: 24801649

import 'package:flutter/material.dart';

import 'package:mescla_mobile/utils/routes.dart';
import 'package:mescla_mobile/utils/app_colors.dart';



class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
  });

  static const List<_NavItem> _items = [
    _NavItem(
      icon: Icons.grid_view_rounded,
      label: 'Catálogo',
    ),
    _NavItem(
      icon: Icons.swap_horiz_rounded,
      label: 'Negociar',
    ),
    _NavItem(
      icon: Icons.account_balance_wallet_rounded,
      label: 'Carteira',
    ),
    _NavItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _NavItem(
      icon: Icons.person_rounded,
      label: 'Perfil',
    ),
  ];

 void _navigate(BuildContext context, int index) {
  if (index == selectedIndex) return;
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => getTelaByIndex(index)),
  );
}

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final selected = index == selectedIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _navigate(context, index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFEFF6FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color: selected ? kPrimary : Colors.blueGrey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: selected ? kPrimary : Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.label,
  });
}