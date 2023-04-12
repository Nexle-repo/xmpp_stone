import 'dart:math';

import 'package:xmpp_stone/src/elements/XmppAttribute.dart';
import 'package:xmpp_stone/src/elements/XmppElement.dart';
import 'package:xmpp_stone/src/elements/forms/XElement.dart';
import 'package:xmpp_stone/src/elements/messages/Amp.dart';
import 'package:xmpp_stone/src/elements/messages/AmpRuleElement.dart';
import 'package:xmpp_stone/src/elements/messages/xmpp_0422/ApplyToElement.dart';
import 'package:xmpp_stone/src/elements/messages/CustomElement.dart';
import 'package:xmpp_stone/src/elements/messages/CustomSubElement.dart';
import 'package:xmpp_stone/src/elements/messages/DelayElement.dart';
import 'package:xmpp_stone/src/elements/messages/xmpp_0422/ChangeMemberRoleElement.dart';
import 'package:xmpp_stone/src/elements/messages/xmpp_0422/ExampleCustomElement.dart';
import 'package:xmpp_stone/src/elements/messages/xmpp_0422/MUCInfoElement.dart';
import 'package:xmpp_stone/src/elements/messages/xmpp_0422/PinnedElement.dart';
import 'package:xmpp_stone/src/elements/messages/ReceiptReceivedElement.dart';
import 'package:xmpp_stone/src/elements/messages/ReceiptRequestElement.dart';
import 'package:xmpp_stone/src/elements/messages/TimeElement.dart';
import 'package:xmpp_stone/src/elements/messages/TimeStampElement.dart';
import 'package:xmpp_stone/src/elements/messages/carbon/ForwardedElement.dart';
import 'package:xmpp_stone/src/elements/messages/carbon/SentElement.dart';
import 'package:xmpp_stone/src/elements/messages/invitation/InviteElement.dart';
import 'package:xmpp_stone/src/elements/messages/mam/ResultElement.dart';
import 'package:xmpp_stone/src/elements/messages/mam/StanzaIdElement.dart';
import 'package:xmpp_stone/src/elements/messages/xmpp_0422/QuoteElement.dart';
import 'package:xmpp_stone/src/elements/messages/xmpp_0422/RecalledElement.dart';
import 'package:xmpp_stone/src/elements/messages/xmpp_0422/system_message_element.dart';
import 'package:xmpp_stone/src/elements/stanzas/AbstractStanza.dart';
import 'package:xmpp_stone/src/extensions/advanced_messaging_processing/AmpInterface.dart';
import 'package:xmpp_stone/src/extensions/apply_to/ApplyToInterface.dart';
import 'package:xmpp_stone/src/extensions/change_member_role/ChangeMemberRoleData.dart';
import 'package:xmpp_stone/src/extensions/example_custom/ExampleCustomInterface.dart';
import 'package:xmpp_stone/src/extensions/mam/ArchiveResultInterface.dart';
import 'package:xmpp_stone/src/extensions/mam/ArchiveStanzaIdInterface.dart';
import 'package:xmpp_stone/src/extensions/message_carbon/SentInterface.dart';
import 'package:xmpp_stone/src/extensions/message_delivery/CustomInterface.dart';
import 'package:xmpp_stone/src/extensions/message_delivery/DelayInterface.dart';
import 'package:xmpp_stone/src/extensions/message_delivery/ReceiptInterface.dart';
import 'package:xmpp_stone/src/extensions/message_delivery/TimeInterface.dart';
import 'package:xmpp_stone/src/extensions/muc_info_data/MUCInfoData.dart';
import 'package:xmpp_stone/src/extensions/multi_user_chat/message_invitation_interface/MessageInvitationInterface.dart';
import 'package:xmpp_stone/src/extensions/quote_message/quote_message.dart';
import '../../extensions/recalled_message/RecalledMessageInterface.dart';
import '../../extensions/system_message/system_message_interface.dart';

class MessageStanza extends AbstractStanza
    implements
        ReceiptInterface,
        TimeInterface,
        AmpInterface,
        CustomInterface,
        DelayInterface,
        SentInterface,
        ArchiveResultInterface,
        ArchiveStanzaIdInterface,
        MessageInvitationInterface,
        ApplyToInterface,
        ExampleCustomInterface,
        SystemMessageInterface,
        RecalledMessageInterface {
  MessageStanzaType? _type;

  MessageStanzaType? get type => _type;

  set type(MessageStanzaType? value) {
    _type = value;
  }

  MessageStanza(id, MessageStanzaType type) {
    name = 'message';
    this.id = id;
    if (type != MessageStanzaType.NONE) {
      _type = type;
      addAttribute(XmppAttribute(
          'type', _type.toString().split('.').last.toLowerCase()));
    }
  }

  String? get body => children
      .firstWhere(
          (child) => (child!.name == 'body' && child.attributes.isEmpty),
          orElse: () => null)
      ?.textValue;

  String? getBodyCarbon({XmppElement? element}) {
    final currentElement = element ?? this;
    final bodyElement = currentElement.children
        .firstWhere((element) => element?.name == 'body', orElse: () => null);
    if (currentElement.children.isEmpty || bodyElement != null) {
      return bodyElement != null
          ? bodyElement.textValue
          : currentElement.name == 'body'
              ? currentElement.textValue
              : null;
    }
    return getBodyCarbon(element: currentElement.children.first);
  }

  set body(String? value) {
    var element = XmppElement();
    element.name = 'body';
    element.textValue = value;
    addChild(element);
  }

  String? get getPinnedValue {
    final applyTo = this.children.firstWhere((element) {
      return element?.name == 'apply-to';
    }, orElse: () => null);
    final pinAction = applyTo?.children.firstWhere((element) {
      return element?.name == 'pin-action';
    }, orElse: () => null);
    return pinAction?.textValue;
  }

  QuoteMessage get quoteData {
    final applyTo = this.children.firstWhere((element) {
      return element?.name == 'apply-to';
    }, orElse: () => null);
    final custom = this.children.firstWhere((element) {
      return element?.name == 'custom';
    }, orElse: () => null);
    ;
    final model = QuoteMessage(
        refMsgId: applyTo?.getAttribute("id")?.value ?? "",
        refMsgShortDesc: custom?.textValue ?? "",
        refMsgType: custom?.getAttribute('type')?.value ?? "",
        refUserId: int.parse(applyTo?.getAttribute("userId")?.value ?? ""),
        refUsername: applyTo?.getAttribute("username")?.value ?? "",
        refMsgTitle: custom?.getAttribute('refMsgTitle')?.value ?? "");
    return model;
  }

  MUCInfoData? get mucInfoData {
    final applyTo = this.children.firstWhere((element) {
      return element?.name == 'apply-to';
    }, orElse: () => null);
    final data = applyTo?.children.firstWhere((element) {
      return element?.name == MUCInfoElement.elementName;
    }, orElse: () => null);
    if (applyTo == null || data == null) return null;
    final model = MUCInfoData(
      subject: data.getAttribute('subject')?.value ?? "",
      coverUrl: data.getAttribute('coverUrl')?.value ?? "",
      membersAddedEncoded: data.getAttribute('membersAddedEncoded')?.value ?? "",
      membersRemovedEncoded: data.getAttribute('membersRemovedEncoded')?.value ?? "",
    );
    return model;
  }

  ChangeMemberRoleData? get changeMemberRoleData {
    final applyTo = this.children.firstWhere((element) {
      return element?.name == 'apply-to';
    }, orElse: () => null);
    final data = applyTo?.children.firstWhere((element) {
      return element?.name == ChangeMemberRoleElement.elementName;
    }, orElse: () => null);
    if (applyTo == null || data == null) return null;
    final model = ChangeMemberRoleData(
      data.getAttribute('userJid')?.value ?? "",
      data.getAttribute('role')?.value ?? "",
    );
    return model;
  }

  List<String>? get getRecalledMessageIds {
    final recalled = this.getRecalledMessage();
    if (recalled != null && recalled.textValue != null) {
      return recalled.textValue!.split(',');
    }
    return null;
  }

  @override
  ApplyToInterface addPinMessage(String messageId, bool isPinned) {
    addChild(ApplyToElement.buildPinMessage(messageId, isPinned));
    return this;
  }

  @override
  ApplyToInterface addQuoteMessage(
      String messageId, String userId, String username) {
    addChild(ApplyToElement.buildQuoteMessage(messageId, userId, username));
    return this;
  }

  @override
  ExampleCustomInterface addQuoteCustom(
      String type, String expts, String text, String refMsgTitle) {
    addChild(ExampleCustomElement.buildQuote(type, expts, text, refMsgTitle));
    return this;
  }

  @override
  ExampleCustomInterface addCustomMessage() {
    addChild(ExampleCustomElement.addCustom());
    return this;
  }

  @override
  SystemMessageInterface addSystemMessage() {
    addChild(SystemMessageElement.addCustom());
    return this;
  }

  @override
  ApplyToInterface addMUCInfo({
    String? subjectChanged,
    String? coverUrlChanged,
    String? membersAddedEncoded,
    String? membersRemovedEncoded,
  }) {
    addChild(ApplyToElement.buildMUCInfo(
      subjectChanged: subjectChanged,
      coverUrlChanged: coverUrlChanged,
      membersAddedEncoded: membersAddedEncoded,
      membersRemovedEncoded: membersRemovedEncoded,
    ));
    return this;
  }

  @override
  bool isMUCInfo() {
    var applyTo = ApplyToElement.parse(this);
    if (applyTo == null) {
      return false;
    }
    var info = MUCInfoElement.parse(applyTo);
    if (info != null) {
      return true;
    }
    return false;
  }

  @override
  XmppElement? getExampleCustom() {
    return ExampleCustomElement.parse(this);
  }

  @override
  bool isCustom() {
    return getExampleCustom() != null;
  }

  @override
  XmppElement? getSystemMessage() {
    return SystemMessageElement.parse(this);
  }

  @override
  bool isSystemMessage() {
    return getSystemMessage() != null;
  }

  @override
  XmppElement? getApplyTo() {
    return ApplyToElement.parse(this);
  }

  @override
  bool isPinMessage() {
    var applyTo = ApplyToElement.parse(this);
    if (applyTo == null) {
      return false;
    }
    var pin = PinnedElement.parse(applyTo);
    if (pin != null) {
      return true;
    }
    return false;
  }

  @override
  bool isQuoteMessage() {
    var applyTo = ApplyToElement.parse(this);
    if (applyTo == null) {
      return false;
    }
    var quote = QuoteElement.parse(applyTo);
    if (quote != null) {
      return true;
    }
    return false;
  }

  String? get subject => children
      .firstWhere((child) => (child!.name == 'subject'), orElse: () => null)
      ?.textValue;

  set subject(String? value) {
    var element = XmppElement();
    element.name = 'subject';
    element.textValue = value;
    addChild(element);
  }

  String? get thread => children
      .firstWhere((child) => (child!.name == 'thread'), orElse: () => null)
      ?.textValue;

  set thread(String? value) {
    var element = XmppElement();
    element.name = 'thread';
    element.textValue = value;
    addChild(element);
  }

  @override
  ReceiptInterface addReceivedReceipt() {
    addChild(ReceiptReceivedElement.build());
    return this;
  }

  @override
  ReceiptInterface addRequestReceipt() {
    addChild(ReceiptRequestElement.build());
    return this;
  }

  @override
  XmppElement? getRequestReceipt() {
    return ReceiptRequestElement.parse(this);
  }

  @override
  XmppElement? getReceivedReceipt() {
    return ReceiptReceivedElement.parse(this);
  }

  @override
  TimeInterface addTime(int? timeMilliseconds) {
    addChild(TimeElement.build(timeMilliseconds.toString()));
    return this;
  }

  @override
  XmppElement? getTime() {
    return TimeStampElement.parse(TimeElement.parse(this));
  }

  @override
  AmpInterface addAmpDeliverDirect() {
    addChild(AmpElement.build([
      AmpRuleElement.build('deliver', 'direct', 'notify'),
      AmpRuleElement.build('deliver', 'stored', 'notify')
    ]));
    return this;
  }

  @override
  XmppElement? getAmp() {
    return AmpElement.parse(this);
  }

  @override
  bool isAmpDeliverDirect() {
    var amp = AmpElement.parse(this);
    if (amp == null) {
      return false;
    }
    var rule = AmpRuleElement.parse(AmpElement.parse(this));
    if (amp == rule) {
      return false;
    }
    return (amp.getAttribute('status')!.value == 'notify' &&
        rule!.getAttribute('condition')!.value == 'deliver' &&
        rule.getAttribute('value')!.value == 'direct');
  }

  @override
  bool isAmpDeliverStore() {
    var amp = AmpElement.parse(this);
    if (amp == null) {
      return false;
    }
    var rule = AmpRuleElement.parse(AmpElement.parse(this));
    if (amp == rule) {
      return false;
    }
    return (amp.getAttribute('status')!.value == 'notify' &&
        rule!.getAttribute('condition')!.value == 'deliver' &&
        rule.getAttribute('value')!.value == 'stored');
  }

  @override
  CustomInterface addCustom(String customString) {
    addChild(CustomElement.build(customString));
    return this;
  }

  @override
  XmppElement? getCustom() {
    return CustomSubElement.parse(CustomElement.parse(this));
  }

  @override
  XmppElement? getDelay() {
    return DelayElement.parse(this);
  }

  @override
  XmppElement? getSent() {
    return SentElement.parse(this);
  }

  @override
  XmppElement? getArchiveResult() {
    return ForwardedElement.parse(SentElement.parse(this));
  }

  @override
  MessageStanza? getArchiveMessage() {
    return ForwardedElement.parseForMessage(SentElement.parse(this));
  }

  @override
  XmppElement? getStanzaId() {
    return StanzaIdElement.parse(this);
  }

  @override
  XmppElement? getInvitation() {
    final xElement = XElement.parse(this);
    if (xElement != null &&
        xElement.getAttribute('xmlns')!.value ==
            'http://jabber.org/protocol/muc#user') {
      return InviteElement.parse(xElement);
    } else {
      return null;
    }
  }

  @override
  RecalledMessageInterface addRecallMessage(
      String fromUserId, String listMessageId) {
    addChild(RecalledElement.build(fromUserId, listMessageId));
    return this;
  }

  @override
  XmppElement? getRecalledMessage() {
    return RecalledElement.parse(this);
  }

  @override
  bool isRecalledMessage() {
    return this.getRecalledMessage() != null;
  }

  @override
  ApplyToInterface changeMemberRole(String userJid, String role) {
    addChild(ApplyToElement.buildChangeMemberRole(userJid, role));
    return this;
  }

  @override
  bool isChangeMemberRole() {
    var applyTo = ApplyToElement.parse(this);
    if (applyTo == null) {
      return false;
    }
    var info = ChangeMemberRoleElement.parse(applyTo);
    if (info != null) {
      return true;
    }
    return false;
  }
}

enum MessageStanzaType {
  CHAT,
  ERROR,
  GROUPCHAT,
  HEADLINE,
  NORMAL,
  UNKOWN,
  NONE
}
