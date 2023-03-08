import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class MUCInfoElement extends XmppElement {
  static String elementName = 'muc-info-changed';
  PinnedElement() {
    name = elementName;
  }

  MUCInfoElement.build({String? subjectChanged, String? coverUrlChanged}) {
    name = elementName;
    String value = '';
    addAttribute(XmppAttribute('xmlns', 'rhp:urn:xmpp:$elementName'));
    if (subjectChanged?.isNotEmpty ?? false) {
      addAttribute(XmppAttribute('subject', subjectChanged));
      value += subjectChanged!;
    }
    if (coverUrlChanged?.isNotEmpty ?? false) {
      addAttribute(XmppAttribute('coverUrl', coverUrlChanged));
      if (value.isNotEmpty) {
        value += '|';
      }
      value += subjectChanged!;
    }
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == MUCInfoElement.elementName),
        orElse: () => null);
  }
}
