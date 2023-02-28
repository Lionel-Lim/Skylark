class Sort {
  List<dynamic> sortByAnotherList(
      List<dynamic> sortList, List<dynamic> anotherList) {
    if (sortList.length != anotherList.length) {
      return [false];
    }
    List<List<dynamic>> combinedList =
        List.generate(sortList.length, (i) => [sortList[i], anotherList[i]]);

    combinedList.sort((a, b) => a[1].compareTo(b[1]));

    sortList = combinedList.map((e) => e[0]).toList();
    anotherList = combinedList.map((e) => e[1]).toList();

    return [sortList, anotherList];
  }
}
