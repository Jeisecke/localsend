/// Information about a network interface including its IP address and subnet
class IpSubnetInfo {
  final String ip;
  final String? subnetMask;

  IpSubnetInfo({required this.ip, this.subnetMask});

  /// Returns true if this is an IPv4 address with a valid subnet mask
  bool get isIpv4WithSubnet {
    final mask = subnetMask;
    return ip.contains('.') && mask != null && mask.contains('.');
  }

  @override
  String toString() => subnetMask != null ? '$ip/$subnetMask' : ip;
}
