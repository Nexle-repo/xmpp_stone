import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class ReactionElement extends XmppElement {
  static String elementName = 'reaction';

  PinnedElement() {
    name = elementName;
  }

  ReactionElement.build(String reaction) {
    name = elementName;
    addAttribute(XmppAttribute('xmlns', 'rhp:urn:xmpp:$elementName'));
    textValue = reaction;
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == ReactionElement.elementName),
        orElse: () => null);
  }
}
