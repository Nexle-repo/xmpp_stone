import 'package:xmpp_stone/src/elements/messages/xmpp_0422/ChangeMemberRoleElement.dart';
import 'package:xmpp_stone/src/elements/messages/xmpp_0422/ExternalElement.dart';
import 'package:xmpp_stone/src/elements/messages/xmpp_0422/PinnedElement.dart';
import 'package:xmpp_stone/src/elements/messages/xmpp_0422/QuoteElement.dart';
import 'package:xmpp_stone/src/elements/messages/xmpp_0422/edit_message_element.dart';
import 'package:xmpp_stone/src/elements/messages/xmpp_0422/pin_chat_element.dart';
import 'package:xmpp_stone/src/elements/messages/xmpp_0422/reaction_element.dart';
import 'package:xmpp_stone/src/extensions/change_member_role/ChangeMemberRoleInterface.dart';
import 'package:xmpp_stone/src/extensions/edit_message/edit_message_interface.dart';
import 'package:xmpp_stone/src/extensions/external/ExternalInterface.dart';
import 'package:xmpp_stone/src/extensions/mark_read/mark_read_data_interface.dart';
import 'package:xmpp_stone/src/extensions/quote_message/QuoteMessageInterface.dart';

import '../../../extensions/muc_info_data/MUCInfoDataInterface.dart';
import '../../../extensions/pin_chat/pin_chat_interface.dart';
import '../../../extensions/pin_message/PinMessageInterface.dart';
import '../../../extensions/react_message/react_message_interface.dart';
import '../../../extensions/read_message/read_message_interface.dart';
import '../../XmppAttribute.dart';
import '../../XmppElement.dart';
import 'MUCInfoElement.dart';
import 'read_message_element.dart';

class ApplyToElement extends XmppElement
    implements
        ChangeMemberRoleInterface,
        MUCInfoDataInterface,
        MarkReadInterface,
        PinMessageInterface,
        PinChatInterface,
        ExternalInterface,
        QuoteMessageInterface,
        ReactMessageInterface,
        EditMessageInterface,
        ReadMessageInterface {
  static String elementName = 'apply-to';

  ApplyToElement() {
    name = elementName;
  }

  ApplyToElement.buildMUCInfo({
    String? subjectChanged,
    String? coverUrlChanged,
    String? membersAddedEncoded,
    String? membersRemovedEncoded,
    bool? isMuted,
    bool? isMarkRead,
    bool? isMarkUnRead,
  }) {
    name = ApplyToElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:fasten:0'));
    addMUCInfo(
      subjectChanged: subjectChanged,
      coverUrlChanged: coverUrlChanged,
      membersAddedEncoded: membersAddedEncoded,
      membersRemovedEncoded: membersRemovedEncoded,
      isMuted: isMuted,
      isMarkUnRead: isMarkUnRead,
      isMarkRead: isMarkRead,
    );
  }

  ApplyToElement.buildChangeMemberRole(String userJid, String role) {
    name = ApplyToElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:fasten:0'));
    addChangeMemberRoleData(userJid, role);
  }

  ApplyToElement.buildPinMessage(String id, bool isPinned) {
    name = ApplyToElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:fasten:0'));
    addAttribute(XmppAttribute('id', id));
    addPinMessage(isPinned);
  }

  ApplyToElement.buildPinChat(String id, bool pinned) {
    name = ApplyToElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:fasten:0'));
    addAttribute(XmppAttribute('id', id));
    addPinChat(id, pinned);
  }

  ApplyToElement.buildQuoteMessage(String id, String userId, String username) {
    name = ApplyToElement.elementName;
    addExternalName("body");
    addQuoteMessage();
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:fasten:0'));
    addAttribute(XmppAttribute('id', id));
    addAttribute(XmppAttribute('userId', userId));
    addAttribute(XmppAttribute('username', username));
  }

  ApplyToElement.buildReactMessage(
    String id,
    String reaction, {
    bool isClear = false,
  }) {
    name = ApplyToElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:fasten:0'));
    addAttribute(XmppAttribute('id', id));
    if (isClear) {
      addAttribute(XmppAttribute('clear', 'true'));
    }
    addReactMessage(reaction);
  }

  ApplyToElement.buildEditMessage(
    String id,
    String content,
  ) {
    name = ApplyToElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:fasten:0'));
    addAttribute(XmppAttribute('id', id));
    editMessage(content);
  }

  ApplyToElement.buildReadMessage(String userId) {
    name = ApplyToElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:fasten:0'));
    addAttribute(XmppAttribute('id', 'any'));
    addReadMessage(userId);
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == ApplyToElement.elementName),
        orElse: () => null);
  }

  @override
  PinMessageInterface addPinMessage(bool isPinned) {
    addChild(PinnedElement.build(isPinned));
    return this;
  }

  @override
  PinChatInterface addPinChat(String chatId, bool pinned) {
    addChild(PinChatElement.build(
      chatId: chatId,
      pinned: pinned,
    ));
    return this;
  }

  @override
  XmppElement? getPinMessage() {
    // TODO: implement getPinMessage
    throw UnimplementedError();
  }

  @override
  QuoteMessageInterface addQuoteMessage() {
    addChild(QuoteElement.build());
    return this;
  }

  @override
  XmppElement? getQuoteMessage() {
    // TODO: implement getQuoteMessage
    throw UnimplementedError();
  }

  @override
  ExternalInterface addExternalName(String name) {
    addChild(ExternalElement.build(name));
    return this;
  }

  @override
  XmppElement? getExternalName() {
    // TODO: implement getExternalName
    throw UnimplementedError();
  }

  @override
  MUCInfoDataInterface addMUCInfo({
    String? subjectChanged,
    String? coverUrlChanged,
    String? membersAddedEncoded,
    String? membersRemovedEncoded,
    bool? isMuted,
    bool? isMarkRead,
    bool? isMarkUnRead,
  }) {
    addChild(MUCInfoElement.build(
      subjectChanged: subjectChanged,
      coverUrlChanged: coverUrlChanged,
      membersAddedEncoded: membersAddedEncoded,
      membersRemovedEncoded: membersRemovedEncoded,
      isMarkRead: isMarkRead,
      isMarkUnRead: isMarkUnRead,
      isMuted: isMuted,
    ));
    return this;
  }

  @override
  XmppElement? getMUCInfo() {
    // TODO: implement getMUCInfoMessage
    throw UnimplementedError();
  }

  @override
  ChangeMemberRoleInterface addChangeMemberRoleData(
      String userJid, String role) {
    addChild(ChangeMemberRoleElement.build(userJid, role));
    return this;
  }

  @override
  XmppElement? getChangeMemberRoleData() {
    // TODO: implement getChangeMemberRoleData
    throw UnimplementedError();
  }

  @override
  XmppElement? getPinChat() {
    // TODO: implement getPinChat
    throw UnimplementedError();
  }

  @override
  ReactMessageInterface addReactMessage(String reaction) {
    addChild(ReactionElement.build(reaction));
    return this;
  }

  @override
  XmppElement? getReactionMessage() {
    // TODO: implement getReactionMessage
    throw UnimplementedError();
  }

  @override
  EditMessageInterface editMessage(String content) {
    addChild(EditMessageElement.build(content));
    return this;
  }

  @override
  XmppElement? getEditMessage() {
    // TODO: implement getEditMessage
    throw UnimplementedError();
  }

  @override
  MarkReadInterface addMarkRead(bool isRead) {
    // TODO: implement addMarkRead
    throw UnimplementedError();
  }

  @override
  XmppElement? getMarkRead() {
    // TODO: implement getMarkRead
    throw UnimplementedError();
  }

  @override
  ReadMessageInterface addReadMessage(String userId) {
    addChild(ReadMessageElement.build(userId));
    return this;
  }

  @override
  XmppElement? getReadMessage() {
    throw UnimplementedError();
  }
}
