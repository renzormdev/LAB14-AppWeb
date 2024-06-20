import 'package:crud/team_database.dart';

class Team {
  final int? id;
  final String name;
  final int foundingYear;
  final DateTime? lastChampDate;

  Team({
    this.id,
    required this.name,
    required this.foundingYear,
    this.lastChampDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'foundingYear': foundingYear,
      'lastChampDate': TeamDatabase.dateTimeToString(lastChampDate),
    };
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'],
      name: map['name'],
      foundingYear: map['foundingYear'],
      lastChampDate: TeamDatabase.stringToDateTime(map['lastChampDate']),
    );
  }
}
