import '../XmppAttribute.dart';
import '../XmppElement.dart';

class CustomIdElement extends XmppElement {
  static String elementName = 'custom-id';
  CustomIdElement() {
    name = elementName;
  }

  CustomIdElement.build(value) {
    name = elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:$elementName'));
    this.textValue = value;
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == CustomIdElement.elementName),
        orElse: () => null);
  }
}
