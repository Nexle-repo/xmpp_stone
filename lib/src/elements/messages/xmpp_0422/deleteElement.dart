import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class DeleteElement extends XmppElement {
  static String elementName = 'retract';
  DeleteElement() {
    name = elementName;
  }

  DeleteElement.build() {
    name = DeleteElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:message-retract:0'));
  }
  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == DeleteElement.elementName),
        orElse: () => null);
  }
}
