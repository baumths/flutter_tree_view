import 'package:flutter/widgets.dart' show BuildContext, MediaQuery;

bool checkIsSmallDisplay(BuildContext context) {
  return MediaQuery.of(context).size.width < 768;
}
