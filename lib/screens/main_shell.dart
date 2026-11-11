import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';
import '../providers/ui_providers.dart';
import 'auth/auth_gate.dart';
import 'home/home_screen.dart';
import 'profile/my_reports_screen.dart';
import 'reports/report_form_screen.dart';
import 'reports/reports_screen.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(shellIndexProvider);
    final userAsync = ref.watch(appUserProvider);

    return userAsync.when(
      // Also covers the brief moment between sign-up and profile-doc creation.
      loading: () => const SplashScreen(),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Could not load profile: $e'))),
      data: (user) {
        if (user == null) return const SplashScreen();
        return Scaffold(
          body: IndexedStack(index: index, children: const [
            HomeScreen(),
            ReportsScreen(),
            MyReportsScreen(),
          ]),
          bottomNavigationBar: _BottomNav(index: index),
        );
      },
    );
  }
}

class _BottomNav extends ConsumerWidget {
  const _BottomNav({required this.index});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void go(int i) => ref.read(shellIndexProvider.notifier).state = i;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: index == 0,
                onTap: () => go(0)),
            _NavItem(
                icon: Icons.description_outlined,
                label: 'Reports',
                selected: index == 1,
                onTap: () => go(1)),
            InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ReportFormScreen())),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Color(0x557C3AED),
                            blurRadius: 10,
                            offset: Offset(0, 4)),
                      ]),
                  child: const Icon(Icons.add, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 2),
                const Text('Report',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ]),
            ),
            _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                selected: index == 2,
                onTap: () => go(2)),
          ]),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}