import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class ChangeMemberRoleElement extends XmppElement {
  static String elementName = 'change-member-role';
  ChangeMemberRoleElement() {
    name = elementName;
  }

  ChangeMemberRoleElement.build(String userJid, String role) {
    name = elementName;
    addAttribute(XmppAttribute('xmlns', 'rhp:urn:xmpp:$elementName'));
    addAttribute(XmppAttribute('userJid', userJid));
    addAttribute(XmppAttribute('role', role));
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == ChangeMemberRoleElement.elementName),
        orElse: () => null);
  }
}
