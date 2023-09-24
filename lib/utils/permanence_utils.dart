class PermanenceUtils {
  static Map<(String messageId, String userId), Map<String, List<String>>>
      messageIdToDtta = {};

  static void storeSession(
    Map<String, List<String>> dayToTimeAvailabilities, {
    required String messageId,
    required String userId,
  }) {
    messageIdToDtta[(messageId, userId)] = dayToTimeAvailabilities;
  }

  static Map<String, List<String>>? fetchSession(
      String messageId, String userId) {
    return messageIdToDtta[(messageId, userId)];
  }
}
