class User {
  final int id;
  final String firstName;
  final String middleName;
  final String lastName;
  final DateTime birthday;
  final String province;
  final String municipality;
  final String barangay;
  final bool isMale;
  final String addressDescription;
  final String zipCode;
  final String contactNumber;
  final int? webId;

  const User({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.isMale,
    required this.addressDescription,
    required this.zipCode,
    required this.contactNumber,
    required this.barangay,
    required this.birthday,
    required this.province,
    required this.municipality,
    required this.webId,
  });

  String get name {
    if (middleName.isEmpty) {
      return "$firstName $lastName";
    } else {
      return "$firstName ${middleName[0]}. $lastName";
    }
  }

  Duration get exactAge {
    return DateTime.now().difference(birthday);
  }

  Map toApiInsertable() {
    return {
      "name": middleName.isEmpty
          ? "$firstName $lastName"
          : "$firstName ${middleName[0]}. $lastName",
      "birthdate": birthday.toIso8601String(),
      "province": province,
      "municipality": municipality,
      "barangay": barangay,
      "zip_code": zipCode,
      "sex": isMale ? "male" : "female",
      "address_description": addressDescription,
      "contact_number": contactNumber,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "first_name": firstName,
      "middle_name": middleName,
      "last_name": lastName,
      "is_male": isMale ? 1 : 0,
      "contact_number": contactNumber,
      "zip_code": zipCode,
      "address_description": addressDescription,
      "barangay": barangay,
      "birthdate": birthday.toIso8601String(),
      "municipality": municipality,
      "province": province,
      "web_id": webId,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map["id"],
      firstName: map["first_name"],
      middleName: map["middle_name"],
      lastName: map["last_name"],
      isMale: map["is_male"] == 1,
      contactNumber: map["contact_number"],
      zipCode: map["zip_code"],
      addressDescription: map["address_description"],
      barangay: map["barangay"],
      birthday: DateTime.parse(map["birthdate"]),
      municipality: map["municipality"],
      province: map["province"],
      webId: map["web_id"],
    );
  }
}
