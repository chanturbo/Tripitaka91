class IPAddress {
  final String ipAddress;
  final bool success;
  final String message;

  IPAddress({
    required this.ipAddress,
    required this.success,
    required this.message,
  });

  factory IPAddress.fromJson(Map<String, dynamic> json) {
    return IPAddress(
      ipAddress: json['ip_address'],
      success: json['success'],
      message: json['message'],
    );
  }
}
