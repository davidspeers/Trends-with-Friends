List<int> addLists(List<int> list1, List<int> list2) {
  if (list1.isEmpty) {
    return list2;
  } else if (list2.isEmpty) {
    return list1;
  } else {
    List<int> returnedList = [];
    for (int i=0; i<list1.length; i++) {
      returnedList.add(list1[i] + list2[i]);
    }
    return returnedList;
  }
}
