import 'dart:math';

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

var _random = new Random();
///From min inclusive to max exclusive
int randomRange(int min, int max) => min + _random.nextInt(max - min);
///From 0 inclusive to max exclusive
double randomDouble(double max) {
  //Got an error in the past where max was -150 and animations didn't occur
  //It said is was a range error and max needed to be between 1 and 2^32
  if (max >= 1.0) {
    return _random.nextInt(max.toInt()).toDouble();
  } else {
    return 1.0;
  }
}
///From min inclusive to max exclusive
double randomDoubleRange(double min, double max) => (min + randomDouble(max - min)).toDouble();

///Get Random Key From Map
randomKey(Map map) => map.keys.elementAt(_random.nextInt(map.length));

randomValFromMap(Map map) => map.values.elementAt(_random.nextInt(map.length));

randomValFromList(List list) => list[_random.nextInt(list.length)];
