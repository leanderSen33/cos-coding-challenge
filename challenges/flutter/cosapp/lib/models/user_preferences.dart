class UserPreferences {
  UserPreferences({required this.id, required this.preferCamera});

  final bool preferCamera;
  final String id;

  factory UserPreferences.fromMap(
      Map<String, dynamic> data, String documentId) {
    final bool preferCamera = data['prefer_camera'];
    return UserPreferences(
      preferCamera: preferCamera ,
        id: documentId);
  }

  Map<String, dynamic> toMap() => {'prefer_camera': preferCamera};
}
