import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omidvpn/api/api/api.dart';
import 'package:omidvpn/api/domain/entity/server_info.dart';
import 'package:omidvpn/ui/server_list/controller/server_list_controller.dart';
import 'package:omidvpn/ui/server_list/widgets/country_selector_widget.dart';
import 'package:omidvpn/ui/server_list/widgets/server_list_item.dart';

class ServerListScreen extends ConsumerWidget
    with ServerListState, ServerListHandler {
  const ServerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.serverListTitle),
        actions: [
          (kDebugMode)
              ? IconButton(
                  onPressed: () => getServerListUsecase(ref, forceRefresh: true),
                  icon: const Icon(Icons.refresh),
                )
              : IconButton(
                  onPressed: () => getServerListUsecase(ref, forceRefresh: true),
                  icon: const Icon(Icons.refresh),
                ),
        ],
      ),
      body: Column(
        children: [
          const CountrySelectorWidget(),
          Expanded(
            child: switch (filteredServerListState(ref)) {
              AsyncLoading<List<ServerInfo>>() => const Center(
                child: CircularProgressIndicator(),
              ),
              AsyncData<List<ServerInfo>>(
                value: final List<ServerInfo> serverList,
              ) =>
                Padding(
                  // Add padding for better 3x UI scaling
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: serverList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ServerListItem(
                        server: serverList[index].copyWith(
                          speed: toMegaBytes(serverList[index].speed),
                          uptime: toDays(serverList[index].uptime),
                          isPremium: serverList[index].isPremium, // Preserve the isPremium flag
                        ),
                        onSelect: () =>
                            selectServerUsecase(ref, server: serverList[index]),
                      );
                    },
                  ),
                ),
              AsyncError<List<ServerInfo>>(:final error) => Center(
                child: Text(error.toString()),
              ),
              _ => const SizedBox.shrink(), // Handles any other AsyncValue states
            },
          ),
        ],
      ),
    );
  }
}