import 'dart:math';

import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class SystemMessageElement extends XmppElement {
  static String elementName = 'system-message';
  SystemMessageElement() {
    name = elementName;
  }

  SystemMessageElement.addCustom() {
    name = SystemMessageElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'rhp:urn:example:$elementName'));
    addAttribute(XmppAttribute('expts', "0"));
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == SystemMessageElement.elementName),
        orElse: () => null);
  }
}
