class UserModel {
  final String userId;
  final String fullName;
  final String email;
  final String university;
  final String course;
  final String? profileImageUrl;
  final String studyLevel;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.university,
    required this.course,
    this.profileImageUrl,
    required this.studyLevel,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> firestore) {
    return UserModel(
      userId: firestore['userId'] as String,
      fullName: firestore['fullName'] as String,
      email: firestore['email'] as String,
      university: firestore['university'] as String,
      course: firestore['course'] as String,
      profileImageUrl: firestore['profileImageUrl'] as String? ??
          'https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg',
      studyLevel: firestore['studyLevel'] as String,
    );
  }
}
