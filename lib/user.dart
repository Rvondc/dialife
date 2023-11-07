class User {
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

  const User({
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

  static User fromMap(Map<String, dynamic> map) {
    return User(
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
    );
  }
}
