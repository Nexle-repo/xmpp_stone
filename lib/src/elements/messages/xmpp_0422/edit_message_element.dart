import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class EditMessageElement extends XmppElement {
  static String elementName = 'edit';

  EditMessageElement() {
    name = elementName;
  }

  EditMessageElement.build() {
    name = elementName;
    addAttribute(XmppAttribute('xmlns', 'rhp:urn:xmpp:$elementName'));
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == EditMessageElement.elementName),
        orElse: () => null);
  }
}
