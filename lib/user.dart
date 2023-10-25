class User {
  final String firstName;
  final String middleName;
  final String lastName;
  final DateTime birthday;
  final String province;
  final String municipality;
  final String barangay;
  final String addressDescription;
  final String zipCode;
  final String contactNumber;

  const User({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.addressDescription,
    required this.zipCode,
    required this.contactNumber,
    required this.barangay,
    required this.birthday,
    required this.province,
    required this.municipality,
  });

  static User fromMap(Map<String, dynamic> map) {
    return User(
      firstName: map["first_name"],
      middleName: map["middle_name"],
      lastName: map["last_name"],
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
