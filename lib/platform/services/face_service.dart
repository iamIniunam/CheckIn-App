abstract class FaceService {
  Future<bool> verifyFace();
  Future<bool> registerFace();
}

class MockFaceVerificationService implements FaceService {
  @override
  Future<bool> verifyFace() async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  @override
  Future<bool> registerFace() async {
    await Future.delayed(const Duration(seconds: 3));
    return true;
  }
}
