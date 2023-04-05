import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class MUCInfoElement extends XmppElement {
  static String elementName = 'muc-info-changed';
  PinnedElement() {
    name = elementName;
  }

  MUCInfoElement.build({
    String? subjectChanged,
    String? coverUrlChanged,
    String? membersAddedEncoded,
    String? membersRemovedEncoded,
  }) {
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
      value += coverUrlChanged!;
    }
    if (membersAddedEncoded?.isNotEmpty ?? false) {
      addAttribute(XmppAttribute('membersAddedEncoded', membersAddedEncoded));
      if (value.isNotEmpty) {
        value += '|';
      }
      value += membersAddedEncoded!;
    }
    if (membersRemovedEncoded?.isNotEmpty ?? false) {
      addAttribute(XmppAttribute('membersRemovedEncoded', membersRemovedEncoded));
      if (value.isNotEmpty) {
        value += '|';
      }
      value += membersRemovedEncoded!;
    }
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == MUCInfoElement.elementName),
        orElse: () => null);
  }
}
