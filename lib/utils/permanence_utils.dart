class PermanenceUtils {
  static Map<String, Map<String, List<String>>> messageIdToDtta = {};

  static void storeSession(
      String messageId, Map<String, List<String>> dayToTimeAvailabilities) {
    messageIdToDtta[messageId] = dayToTimeAvailabilities;
  }

  static Map<String, List<String>>? fetchSession(String messageId) {
    return messageIdToDtta[messageId];
  }
}
