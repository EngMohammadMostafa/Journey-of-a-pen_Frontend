class CompetitionModel {
  final int id;
  final String name;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final int maxUser;

  CompetitionModel({
    required this.id,
    required this.name,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.maxUser,
  });

  factory CompetitionModel.fromJson(Map<String, dynamic> json) {
    return CompetitionModel(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      startDate: DateTime.parse(json['startdate']),
      endDate: DateTime.parse(json['enddate']),
      maxUser: json['max_user'],
    );
  }
}
