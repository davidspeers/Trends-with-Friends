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

String toTitleCase(String str) {
  var splitStr = str.toLowerCase().split(' ');
  for (var i = 0; i < splitStr.length; i++) {
    // You do not need to check if i is larger than splitStr length, as your for does that for you
    // Assign it back to the array
    splitStr[i] = splitStr[i][0].toUpperCase() + splitStr[i].substring(1);
  }
  // Directly return the joined string
  return splitStr.join(' ');
}