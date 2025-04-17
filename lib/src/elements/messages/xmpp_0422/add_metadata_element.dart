import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class AddMetadataElement extends XmppElement {
  static String elementName = 'addMetadata';

  AddMetadataElement() {
    name = elementName;
  }

  AddMetadataElement.build() {
    name = elementName;
    addAttribute(XmppAttribute('xmlns', 'rhp:urn:xmpp:$elementName'));
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == AddMetadataElement.elementName),
        orElse: () => null);
  }
}
