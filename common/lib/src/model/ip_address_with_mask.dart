/// Represents an IP address with its associated subnet mask
class IpAddressWithMask {
  final String ip;
  final String? mask;

  IpAddressWithMask({required this.ip, this.mask});

  /// Returns true if this is an IPv4 address with a valid mask
  bool get isIpv4WithMask {
    final subnetMask = mask;
    return ip.contains('.') && subnetMask != null && subnetMask.contains('.');
  }

  @override
  String toString() => mask != null ? '$ip/$mask' : ip;
}
