import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd(); // Solo se carga UNA vez cuando el widget nace
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-3940256099942544/6300978111', // ID de prueba oficial
      request: const AdRequest(),
      size: AdSize.largeBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          // El if (mounted) es VITAL para evitar tu error de la pantalla roja
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd falló al cargar: $err');
          ad.dispose(); // Liberar memoria si falla
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    // Si el usuario cambia de pantalla, destruimos el anuncio limpiamente
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si ya cargó, mostramos el anuncio con su tamaño exacto
    if (_isLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Mientras carga, o si falla, devolvemos un espacio vacío para no romper tu UI
    return const SizedBox(height: 50);
  }
}
