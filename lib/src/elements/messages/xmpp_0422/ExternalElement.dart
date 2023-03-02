import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class ExternalElement extends XmppElement {
  static String elementName = 'external';
  PinnedElement() {
    name = elementName;
  }

  ExternalElement.build(String value) {
    name = elementName;
    addAttribute(XmppAttribute('name', value));
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == ExternalElement.elementName),
        orElse: () => null);
  }
}
