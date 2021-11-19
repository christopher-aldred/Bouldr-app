class SearchFunctions {
  static List<String> getSearchTerms(String name) {
    Set<String> caseSearch = <String>{};

    var split = name.toLowerCase().split(" ");
    Set<String> phrases = split.toSet();

    phrases.add(name.toLowerCase());

    for (int i = 0; i < split.length - 1; i++) {
      phrases.add(split[i] + " " + split[i + 1]);
    }

    phrases.forEach((word) {
      for (int i = 0; i < word.length; i++) {
        String subForm = word.substring(0, word.length - i);
        if (subForm.substring(0, 1) == " " ||
            subForm.substring(subForm.length - 1) == " ") {
          return;
        }
        caseSearch.add(subForm);
      }
      for (int i = word.length - 1; i >= 0; i--) {
        String subForm = word.substring(i, word.length);
        if (subForm.substring(0, 1) == " " ||
            subForm.substring(subForm.length - 1) == " ") {
          return;
        }
        caseSearch.add(subForm);
      }
    });

    return caseSearch.toList();
  }
}
