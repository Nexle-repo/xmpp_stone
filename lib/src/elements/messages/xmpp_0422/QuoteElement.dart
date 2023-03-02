import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class QuoteElement extends XmppElement {
  static String elementName = 'quote';
  QuoteElement() {
    name = elementName;
  }

  QuoteElement.build() {
    name = QuoteElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'rhp:urn:xmpp:quote'));
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == QuoteElement.elementName),
        orElse: () => null);
  }
}
