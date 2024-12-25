import 'package:xmpp_stone/xmpp_stone.dart';

/// Inspired by this XEP-0333: https://xmpp.org/extensions/xep-0333.html

abstract class DisplayedMarkerInterface {
  DisplayedMarkerInterface addDisplayMarker(String id);
  XmppElement? getDisplayMarker();
  bool isDisplayedMarkerMessage();
}
