class RecentService {

  static List<Map<String, String>> recentFiles = [];

  static void addRecent(
      String name,
      String type,
      String product,
      ) {
    recentFiles.removeWhere(
          (file) => file["name"] == name,
    );

    recentFiles.insert(0, {
      "name": name,
      "type": type,
      "product": product,
    });

    if (recentFiles.length > 3) {
      recentFiles.removeLast();
    }
  }
}