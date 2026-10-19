import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omidvpn/api/api/api.dart';
import 'package:omidvpn/api/domain/entity/vpn_stage.dart';
import 'package:omidvpn/ui/home/controller/home_controller.dart';
import 'package:omidvpn/api/domain/entity/server_info.dart';

class HomePage extends ConsumerWidget with HomeState, HomeHandler {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final server = serverInfo(ref);
    final vpnstage = vpnStage(ref);

    return Scaffold(
      body: Stack(
        children: [
          // Background (Optional: Add a gradient or image here later)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Theme.of(context).colorScheme.primaryContainer,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Custom Header with App Name
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lang.homeTitle,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(flex: 2, child: Container()), // Spacer
                Expanded(
                  flex: 4,
                  child: Center(
                    child: (server != null)
                        ? (vpnstage == VpnStage.disconnected)
                            ? _buildConnectButton(context, ref, server, lang)
                            : _buildDisconnectButton(context, ref, lang)
                        : _buildNoServerSelectedState(context, lang),
                  ),
                ),
                _buildServerInfoCard(context, ref, server, vpnstage, lang),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: SizedBox(
                      width: 250,
                      height: 60,
                      child: FilledButton.icon(
                        onPressed: () => selectServerUsecase(ref),
                        icon: const Icon(Icons.list, size: 30),
                        label: Text(
                          lang.selectServer,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectButton(BuildContext context, WidgetRef ref, ServerInfo server, dynamic lang) {
    return SizedBox(
      width: 180, // Slightly larger button
      height: 180, // Slightly larger button
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background map image
          Positioned.fill(
            child: ClipOval(
              child: Image.asset(
                'assets/map.png',
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3), // Darken the map a bit
                colorBlendMode: BlendMode.darken,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.grey.withOpacity(0.3)); // Fallback
                },
              ),
            ),
          ),
          // Connect button
          FilledButton(
            onPressed: () => connectUsecase(ref, server: server),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent, // Make button transparent to show map
              foregroundColor: Colors.white, // Icon/text color
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(30),
              side: const BorderSide(color: Colors.white54, width: 2), // Add a subtle border
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.power_settings_new,
                  size: 60,
                ),
                const SizedBox(height: 5),
                Text(
                  lang.connectButton,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisconnectButton(BuildContext context, WidgetRef ref, dynamic lang) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background map image
          Positioned.fill(
            child: ClipOval(
              child: Image.asset(
                'assets/map.png',
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3), // Darken the map a bit
                colorBlendMode: BlendMode.darken,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.grey.withOpacity(0.3)); // Fallback
                },
              ),
            ),
          ),
          // Disconnect button
          FilledButton(
            onPressed: () => disconnectUsecase(ref),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.7), // Red transparent background
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(30),
              side: const BorderSide(color: Colors.white54, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.power_off,
                  size: 60,
                ),
                const SizedBox(height: 5),
                Text(
                  lang.disconnectButton,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoServerSelectedState(BuildContext context, dynamic lang) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.power_settings_new,
          size: 100,
          color: Colors.white70, // Lighter grey for modern feel
        ),
        SizedBox(height: 16),
        Text(
          lang.notSelected,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          lang.selectServerToConnect,
          style: TextStyle(fontSize: 16, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildServerInfoCard(BuildContext context, WidgetRef ref, ServerInfo? server, VpnStage vpnstage, dynamic lang) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black;
    final textSecondary = isDark ? Colors.white70 : Colors.black87;
    final textMuted = isDark ? Colors.white54 : Colors.black54;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: server != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  (() {
                    final countryCode = server.countryShort.toLowerCase();
                    final flagAssetPath = 'assets/CountryFlags/$countryCode.png';
                    return Image.asset(
                      flagAssetPath,
                      width: 60,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                      fit: BoxFit.contain,
                    );
                  })(),
                  const SizedBox(height: 12),
                  Text(
                    server.hostName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${server.countryLong} (${server.countryShort})',
                    style: TextStyle(fontSize: 16, color: textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: vpnstage == VpnStage.connected
                          ? Colors.green.shade600
                          : vpnstage == VpnStage.disconnected
                              ? Colors.red.shade600
                              : Colors.orange.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vpnstage.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 40, color: textMuted),
                  const SizedBox(height: 12),
                  Text(
                    lang.notSelected,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lang.pleaseSelectServer,
                    style: TextStyle(fontSize: 14, color: textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}