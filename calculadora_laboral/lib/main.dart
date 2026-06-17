import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/net_salary_screen.dart';
import 'presentation/screens/gratification_screen.dart';
import 'presentation/screens/cts_screen.dart';
import 'presentation/screens/liquidation_screen.dart';
// import 'presentation/screens/info_screen.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(
    // ProviderScope es el contenedor raíz de Riverpod
    const ProviderScope(child: CalculadoraLaboralApp()),
  );
}

class CalculadoraLaboralApp extends StatelessWidget {
  const CalculadoraLaboralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Laboral PE',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const MainShell(),
    );
  }
}

/// Shell principal con NavigationBar de 5 tabs.
///
/// Mantiene el estado de navegación con [IndexedStack] para preservar
/// el scroll y estado de cada tab al cambiar entre ellos.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _tabs = [
    _TabItem(
      label: 'Neto',
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      screen: NetSalaryScreen(),
      appBarTitle: 'Sueldo Neto Mensual',
    ),
    _TabItem(
      label: 'Gratif.',
      icon: Icons.card_giftcard_outlined,
      activeIcon: Icons.card_giftcard_rounded,
      screen: GratificationScreen(),
      appBarTitle: 'Gratificación',
    ),
    _TabItem(
      label: 'CTS',
      icon: Icons.savings_outlined,
      activeIcon: Icons.savings_rounded,
      screen: CtsScreen(),
      appBarTitle: 'CTS Semestral',
    ),
    _TabItem(
      label: 'Liquidac.',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      screen: LiquidationScreen(),
      appBarTitle: 'Liquidación Total',
    ),
    /*
    _TabItem(
      label: 'Info',
      icon: Icons.info_outline_rounded,
      activeIcon: Icons.info_rounded,
      screen: InfoScreen(),
      appBarTitle: 'Parámetros Legales 2026',
    ),
    */
  ];

  @override
  Widget build(BuildContext context) {
    final currentTab = _tabs[_currentIndex];

    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.work_rounded,
                  size: 18,
                  color: Color(0xFF444444),
                ),
              ),
              Text(currentTab.appBarTitle),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: const Text('🇵🇪 2026',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333))),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      // IndexedStack preserva el estado de cada tab (scroll, controllers)
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.map((t) => t.screen).toList(),
      ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE0E4ED), width: 1)),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) =>
                setState(() => _currentIndex = index),
            destinations: _tabs
                .map(
                  (t) => NavigationDestination(
                    icon: Icon(t.icon),
                    selectedIcon: Icon(t.activeIcon),
                    label: t.label,
                  ),
                )
                .toList(),
            animationDuration: const Duration(milliseconds: 300),
          ),
        ),
    );
  }
}

/// Modelo de datos de cada tab de la NavigationBar.
class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget screen;
  final String appBarTitle;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.screen,
    required this.appBarTitle,
  });
}
