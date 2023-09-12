class RecentUsers {
  String? username;
  String? walletAddress;

  RecentUsers({this.username, this.walletAddress});

  RecentUsers.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    walletAddress = json['walletAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['walletAddress'] = walletAddress;
    return data;
  }
}
