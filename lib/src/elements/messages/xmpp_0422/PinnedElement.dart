import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class PinnedElement extends XmppElement {
  static String elementName = 'pin-action';
  PinnedElement() {
    name = elementName;
  }

  PinnedElement.build(bool isPinned) {
    name = elementName;
    addAttribute(XmppAttribute('xmlns', 'rhp:urn:xmpp:pin'));
    textValue = isPinned ? "1" : "0";
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == PinnedElement.elementName),
        orElse: () => null);
  }
}
