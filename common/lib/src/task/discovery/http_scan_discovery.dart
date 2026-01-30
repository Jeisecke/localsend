import 'package:common/model/device.dart';
import 'package:common/src/task/discovery/http_target_discovery.dart';
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

  Stream<Device> getStream({
    required String networkInterface,
    required int port,
    required bool https,
    int? scanRange, // Number of addresses to scan (256 for /24, 65536 for /16)
  }) {
    final range = scanRange ?? 256; // Default to /24 for backward compatibility
    final List<String> ipList;
    
    // Validate IPv4 address format
    final parts = networkInterface.split('.');
    if (parts.length != 4) {
      _logger.warning('Invalid IPv4 address format: $networkInterface, defaulting to /24 scan');
      ipList = _generateSubnet24IPs(networkInterface);
    } else if (range == 65536) {
      // /16 network: scan last two octets (192.168.0.0 - 192.168.255.255)
      ipList = _generateSubnet16IPs(parts, networkInterface);
    } else {
      // /24 network: scan last octet (192.168.1.0 - 192.168.1.255)
      ipList = _generateSubnet24IPs(networkInterface);
    }
    
    _runners[networkInterface]?.stop();
    _runners[networkInterface] = TaskRunner<Device?>(
      initialTasks: List.generate(
        ipList.length,
        (index) => () async => _doRequest(ipList[index], port, https),
      ),
      concurrency: 50,
    );

    return _runners[networkInterface]!.stream.where((device) => device != null).cast<Device>();
  }

  /// Generates IP addresses for /24 subnet (last octet varies)
  List<String> _generateSubnet24IPs(String networkInterface) {
    return List.generate(
      256,
      (i) => '${networkInterface.split('.').take(3).join('.')}.$i',
    ).where((ip) => ip != networkInterface).toList();
  }

  /// Generates IP addresses for /16 subnet (last two octets vary)
  /// Prioritizes IPs closer to the current device's third octet for faster discovery
  List<String> _generateSubnet16IPs(List<String> parts, String networkInterface) {
    final baseIp = '${parts[0]}.${parts[1]}';
    final currentThirdOctet = int.parse(parts[2]);
    final ipList = <String>[];

    // Start from current third octet and spiral outward for better performance
    // This prioritizes nearby devices which are more likely to be relevant
    final visited = <int>{};
    var distance = 0;

    while (visited.length < 256) {
      // Try currentThirdOctet + distance
      final upper = currentThirdOctet + distance;
      if (upper < 256 && !visited.contains(upper)) {
        visited.add(upper);
        for (int j = 0; j < 256; j++) {
          final ip = '$baseIp.$upper.$j';
          if (ip != networkInterface) {
            ipList.add(ip);
          }
        }
      }

      // Try currentThirdOctet - distance (if distance > 0 to avoid duplicates)
      if (distance > 0) {
        final lower = currentThirdOctet - distance;
        if (lower >= 0 && !visited.contains(lower)) {
          visited.add(lower);
          for (int j = 0; j < 256; j++) {
            final ip = '$baseIp.$lower.$j';
            if (ip != networkInterface) {
              ipList.add(ip);
            }
          }
        }
      }

      distance++;
    }

    return ipList;
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
