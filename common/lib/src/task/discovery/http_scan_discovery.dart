import 'package:common/model/device.dart';
import 'package:common/src/model/ip_subnet_info.dart';
import 'package:common/src/task/discovery/http_target_discovery.dart';
import 'package:common/src/util/ip_range_calculator.dart';
import 'package:common/util/task_runner.dart';
import 'package:logging/logging.dart';
import 'package:refena/refena.dart';

final _logger = Logger('HttpScanDiscovery');

final httpScanDiscoveryProvider = ViewProvider((ref) {
  return HttpScanDiscoveryService(
    targetedDiscoveryService: ref.accessor(httpTargetDiscoveryProvider),
  );
});

Map<String, TaskRunner> _runners = {};

class HttpScanDiscoveryService {
  final StateAccessor<HttpTargetDiscoveryService> _targetedDiscoveryService;

  HttpScanDiscoveryService({
    required StateAccessor<HttpTargetDiscoveryService> targetedDiscoveryService,
  }) : _targetedDiscoveryService = targetedDiscoveryService;

  Stream<Device> getStream({required String networkInterfaceWithMask, required int port, required bool https}) {
    // Parse the network interface with mask (format: IP/MASK or just IP)
    final parts = networkInterfaceWithMask.split('/');
    final ip = parts[0];
    final mask = parts.length > 1 ? parts[1] : null;
    
    // Calculate IP range based on subnet mask
    final ipList = IpRangeCalculator.calculateSimpleRange(ip, mask)
        .where((ip) => ip != networkInterfaceWithMask.split('/')[0]) // Exclude the device's own IP
        .toList();
    
    _runners[networkInterfaceWithMask]?.stop();
    _runners[networkInterfaceWithMask] = TaskRunner<Device?>(
      initialTasks: List.generate(
        ipList.length,
        (index) => () async => _doRequest(ipList[index], port, https),
      ),
      concurrency: 50,
    );

    return _runners[networkInterfaceWithMask]!.stream.where((device) => device != null).cast<Device>();
  }

  Stream<Device> getFavoriteStream({required List<(String, int)> devices, required bool https}) {
    final runner = TaskRunner<Device?>(
      initialTasks: List.generate(
        devices.length,
        (index) => () async {
          final device = devices[index];
          return _doRequest(device.$1, device.$2, https);
        },
      ),
      concurrency: 50,
    );

    return runner.stream.where((device) => device != null).cast<Device>();
  }

  Future<Device?> _doRequest(String currentIp, int port, bool https) async {
    _logger.fine('Requesting $currentIp');
    final device = await _targetedDiscoveryService.state.discover(
      ip: currentIp,
      port: port,
      https: https,
      onError: null,
    );
    if (device != null) {
      _logger.info('[DISCOVER/TCP] ${device.alias} (${device.ip}, model: ${device.deviceModel})');
    }

    return device;
  }
}
