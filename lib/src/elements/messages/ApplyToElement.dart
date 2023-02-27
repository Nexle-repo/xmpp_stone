import 'package:xmpp_stone/src/elements/messages/PinnedElement.dart';

import '../../extensions/pin_message/PinMessageInterface.dart';
import '../XmppAttribute.dart';
import '../XmppElement.dart';

class ApplyToElement extends XmppElement implements PinMessageInterface {
  static String elementName = 'apply-to';
  ApplyToElement() {
    name = elementName;
  }

  ApplyToElement.buildPinMessage(String id, bool isPinned) {
    name = ApplyToElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:fasten:0'));
    addAttribute(XmppAttribute('id', id));
    addPinMessage(isPinned);
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == ApplyToElement.elementName),
        orElse: () => null);
  }
  
  @override
  PinMessageInterface addPinMessage(bool isPinned) {
    addChild(PinnedElement.build(isPinned));
    return this;
  }
  
  @override
  XmppElement? getPinMessage() {
    return PinnedElement.parse(this);
  }
}
