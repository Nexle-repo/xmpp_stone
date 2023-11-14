import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class MUCInfoElement extends XmppElement {
  static String elementName = 'muc-info-changed';
  MUCInfoElement() {
    name = elementName;
  }

  MUCInfoElement.build({
    String? subjectChanged,
    String? coverUrlChanged,
    String? membersAddedEncoded,
    String? membersRemovedEncoded,
    bool? isMuted,
    bool? isMarkRead,
    bool? isMarkUnRead,
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
      addAttribute(
        XmppAttribute('membersRemovedEncoded', membersRemovedEncoded),
      );
      if (value.isNotEmpty) {
        value += '|';
      }
      value += membersRemovedEncoded!;
    }
    if (isMuted != null) {
      final muted = isMuted ? '1' : '0';
      addAttribute(
        XmppAttribute('isMuted', muted),
      );
      if (value.isNotEmpty) {
        value += '|';
      }
      value += muted;
    }
    if (isMarkRead != null) {
      final markRead = isMarkRead ? '1' : '0';
      addAttribute(
        XmppAttribute('isMarkRead', markRead),
      );
      if (value.isNotEmpty) {
        value += '|';
      }
      value += markRead;
    }
    if (isMarkUnRead != null) {
      final markUnRead = isMarkUnRead ? '1' : '0';
      addAttribute(
        XmppAttribute('isMarkUnRead', markUnRead),
      );
      if (value.isNotEmpty) {
        value += '|';
      }
      value += markUnRead;
    }
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == MUCInfoElement.elementName),
        orElse: () => null);
  }
}
