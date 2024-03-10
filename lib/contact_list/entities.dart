class Doctor {
  final int id;
  final String? facebookId;
  final String name;
  final String address;
  final String description;
  final String? phoneNumber;

  static Doctor fromMap(Map<String, dynamic> map) {
    return Doctor(
        id: map["id"],
        facebookId: map["facebook_id"],
        name: map["name"],
        address: map["address"],
        description: map["description"],
        phoneNumber: map["contact_number"]);
  }

  static List<Doctor> fromListOfMaps(List<Map<String, dynamic>> list) {
    final result = list.map((record) => fromMap(record));

    return result.toList();
  }

  const Doctor({
    required this.id,
    required this.facebookId,
    required this.name,
    required this.address,
    required this.description,
    required this.phoneNumber,
  });
}
