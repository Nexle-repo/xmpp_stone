import 'dart:async';

import 'package:xmpp_stone/src/Connection.dart';
import 'package:xmpp_stone/src/access_point/communication_config.dart';
import 'package:xmpp_stone/src/data/Jid.dart';
import 'package:xmpp_stone/src/elements/encryption/EncryptElement.dart';
import 'package:xmpp_stone/src/elements/stanzas/AbstractStanza.dart';
import 'package:xmpp_stone/src/elements/stanzas/MessageStanza.dart';
import 'package:xmpp_stone/src/exception/XmppException.dart';
import 'package:xmpp_stone/src/extensions/advanced_messaging_processing/AmpManager.dart';
import 'package:xmpp_stone/src/extensions/chat_states/ChatStateDecoration.dart';
import 'package:xmpp_stone/src/extensions/message_delivery/ReceiptInterface.dart';
import 'package:xmpp_stone/src/messages/MessageApi.dart';
import 'package:xmpp_stone/src/messages/MessageParams.dart';
import 'package:xmpp_stone/src/response/Response.dart';

class MessageHandler implements MessageApi {
  static Map<Connection?, MessageHandler> instances =
      <Connection?, MessageHandler>{};

  final ResponseHandler<MessageStanza> responseHandler =
      ResponseHandler<MessageStanza>();

  Stream<MessageStanza?> get messagesStream {
    return _connection!.inStanzasStream.where((abstractStanza) {
      return abstractStanza is MessageStanza;
    }).map((stanza) => stanza as MessageStanza?);
  }

  static MessageHandler getInstance(Connection? connection) {
    var manager = instances[connection];
    if (manager == null) {
      manager = MessageHandler(connection);
      instances[connection] = manager;
    }

    return manager;
  }

  Connection? _connection;

  MessageHandler(Connection? connection) {
    _connection = connection;

    _connection!.connectionStateStream.listen(_connectionStateHandler);
  }

  @override
  Future<MessageStanza> sendMessage(Jid? to, String text, bool isCustom,
      {MessageParams additional = const MessageParams(
        millisecondTs: 0,
        customString: '',
        messageId: '',
        receipt: ReceiptRequestType.NONE,
        messageType: MessageStanzaType.CHAT,
        chatStateType: ChatStateType.None,
        ampMessageType: AmpMessageType.None,
        hasEncryptedBody: false,
        options: XmppCommunicationConfig(shallWaitStanza: false),
      )}) {
    return _sendMessageStanza(to, text, isCustom, additional, null);
  }

  @override
  Future<MessageStanza> sendSystemMessage(
    Jid? to,
    String text, {
    MessageParams additional = const MessageParams(
      millisecondTs: 0,
      customString: '',
      messageId: '',
      receipt: ReceiptRequestType.NONE,
      messageType: MessageStanzaType.CHAT,
      chatStateType: ChatStateType.None,
      ampMessageType: AmpMessageType.None,
      hasEncryptedBody: false,
      options: XmppCommunicationConfig(shallWaitStanza: false),
    ),
  }) {
    return _sendSystemMessageStanza(to, text, additional, null);
  }

  Future<MessageStanza> sendState(
    Jid? to,
    MessageStanzaType messageType,
    ChatStateType chatStateType,
  ) {
    return _sendMessageStanza(
        to,
        '',
        false,
        MessageParams(
            millisecondTs: 0,
            customString: '',
            messageId: '',
            receipt: ReceiptRequestType.NONE,
            messageType: messageType,
            chatStateType: chatStateType,
            ampMessageType: AmpMessageType.None,
            hasEncryptedBody: false,
            options: XmppCommunicationConfig(shallWaitStanza: false)),
        null);
  }

  Future<MessageStanza> _sendMessageStanza(Jid? jid, String text, bool isCustom,
      MessageParams additional, EncryptElement? encryptElement) async {
    final stanza = MessageStanza(
        additional.messageId.isEmpty
            ? AbstractStanza.getRandomId()
            : additional.messageId,
        additional.messageType);
    stanza.toJid = jid;
    stanza.fromJid = _connection!.fullJid;
    // Validation
    if (stanza.toJid == null || stanza.fromJid == null) {
      throw InvalidJidMessageStanzaException();
    }

    if (additional.hasEncryptedBody && encryptElement != null) {
      stanza.addChild(encryptElement);
    } else {
      if (text.isNotEmpty) {
        stanza.body = text;
      }
      if (additional.millisecondTs != 0) {
        stanza.addTime(additional.millisecondTs);
      }

      if (additional.customString.isNotEmpty) {
        stanza.addCustom(additional.customString);
      }

      if (additional.chatStateType != ChatStateType.None) {
        ChatStateDecoration(message: stanza).setState(additional.chatStateType);
      }
    }

    // For custome message
    if (isCustom) {
      stanza.addCustomMessage();
    }

    // Add receipt delivery
    if (additional.receipt == ReceiptRequestType.RECEIVED) {
      stanza.addReceivedReceipt();
    } else if (additional.receipt == ReceiptRequestType.REQUEST) {
      stanza.addRequestReceipt();
    }

    if (additional.ampMessageType == AmpMessageType.Delivery) {
      // Add request stanza from server?
      stanza.addAmpDeliverDirect();
    }

    await _connection!.writeStanzaWithQueue(stanza);

    return stanza;
    // Could not wait for the ack, there is no ack sent (r, c type)
    // return responseHandler.set<MessageStanza>(stanza.id!, stanza);
  }

  Future<MessageStanza> _sendSystemMessageStanza(Jid? jid, String text,
      MessageParams additional, EncryptElement? encryptElement) async {
    final stanza = MessageStanza(
        additional.messageId.isEmpty
            ? AbstractStanza.getRandomId()
            : additional.messageId,
        additional.messageType);
    stanza.toJid = jid;
    stanza.fromJid = _connection!.fullJid;
    // Validation
    if (stanza.toJid == null || stanza.fromJid == null) {
      throw InvalidJidMessageStanzaException();
    }

    if (additional.hasEncryptedBody && encryptElement != null) {
      stanza.addChild(encryptElement);
    } else {
      if (text.isNotEmpty) {
        stanza.body = text;
      }
      if (additional.millisecondTs != 0) {
        stanza.addTime(additional.millisecondTs);
      }

      if (additional.customString.isNotEmpty) {
        stanza.addCustom(additional.customString);
      }

      if (additional.chatStateType != ChatStateType.None) {
        ChatStateDecoration(message: stanza).setState(additional.chatStateType);
      }
    }

    // For custome message
    stanza.addSystemMessage();

    // Add receipt delivery
    if (additional.receipt == ReceiptRequestType.RECEIVED) {
      stanza.addReceivedReceipt();
    } else if (additional.receipt == ReceiptRequestType.REQUEST) {
      stanza.addRequestReceipt();
    }

    if (additional.ampMessageType == AmpMessageType.Delivery) {
      // Add request stanza from server?
      stanza.addAmpDeliverDirect();
    }

    await _connection!.writeStanzaWithQueue(stanza);

    return stanza;
    // Could not wait for the ack, there is no ack sent (r, c type)
    // return responseHandler.set<MessageStanza>(stanza.id!, stanza);
  }

  void _connectionStateHandler(XmppConnectionState state) {
    if (state == XmppConnectionState.Ready) {
      _connection!.streamManagementModule.deliveredStanzasStream
          .where((abstractStanza) => abstractStanza is MessageStanza)
          .map((stanza) => stanza as MessageStanza)
          .listen(_processDeliveryStanza);
    }
  }

  void _processDeliveryStanza(AbstractStanza nonza) {
    responseHandler.test(nonza.id!, (item) {
      switch (item.item3) {
        case MessageStanza:
          item.item2.complete(item.item1);
          break;
      }
    });
  }

  @override
  Future<MessageStanza> sendSecureMessage(Jid to, EncryptElement encryptElement,
      {MessageParams additional = const MessageParams(
          millisecondTs: 0,
          customString: '',
          messageId: '',
          receipt: ReceiptRequestType.NONE,
          messageType: MessageStanzaType.CHAT,
          chatStateType: ChatStateType.None,
          ampMessageType: AmpMessageType.None,
          options: XmppCommunicationConfig(shallWaitStanza: false),
          hasEncryptedBody: false)}) {
    return _sendMessageStanza(to, '', false, additional, encryptElement);
  }

  @override
  Future<MessageStanza> pinMessage(Jid to, String messageId, bool isPinned,
      {MessageParams additional = const MessageParams(
        millisecondTs: 0,
        customString: '',
        messageId: '',
        receipt: ReceiptRequestType.NONE,
        messageType: MessageStanzaType.CHAT,
        chatStateType: ChatStateType.None,
        ampMessageType: AmpMessageType.None,
        hasEncryptedBody: false,
        options: XmppCommunicationConfig(shallWaitStanza: false),
      )}) {
    return _pinMessageStanza(to, messageId, isPinned, additional);
  }

  Future<MessageStanza> _pinMessageStanza(Jid? jid, String messageId,
      bool isPinned, MessageParams additional) async {
    final stanza = MessageStanza(
        additional.messageId.isEmpty
            ? AbstractStanza.getRandomId()
            : additional.messageId,
        additional.messageType);
    stanza.toJid = jid;
    stanza.fromJid = _connection!.fullJid;
    // Validation
    if (stanza.toJid == null || stanza.fromJid == null) {
      throw InvalidJidMessageStanzaException();
    }

    stanza.addPinMessage(messageId, isPinned);

    if (additional.millisecondTs != 0) {
      stanza.addTime(additional.millisecondTs);
    }

    if (additional.customString.isNotEmpty) {
      stanza.addCustom(additional.customString);
    }

    if (additional.chatStateType != ChatStateType.None) {
      ChatStateDecoration(message: stanza).setState(additional.chatStateType);
    }

    // Add receipt delivery
    if (additional.receipt == ReceiptRequestType.RECEIVED) {
      stanza.addReceivedReceipt();
    } else if (additional.receipt == ReceiptRequestType.REQUEST) {
      stanza.addRequestReceipt();
    }

    if (additional.ampMessageType == AmpMessageType.Delivery) {
      // Add request stanza from server?
      stanza.addAmpDeliverDirect();
    }

    await _connection!.writeStanzaWithQueue(stanza);

    return stanza;
    // Could not wait for the ack, there is no ack sent (r, c type)
    // return responseHandler.set<MessageStanza>(stanza.id!, stanza);
  }

  @override
  Future<MessageStanza> pinChat(
    Jid to,
    bool isPinned, {
    MessageParams additional = const MessageParams(
      millisecondTs: 0,
      customString: '',
      messageId: '',
      receipt: ReceiptRequestType.NONE,
      messageType: MessageStanzaType.CHAT,
      chatStateType: ChatStateType.None,
      ampMessageType: AmpMessageType.None,
      hasEncryptedBody: false,
      options: XmppCommunicationConfig(shallWaitStanza: false),
    ),
  }) {
    return _pinChatStanza(to, isPinned, additional);
  }

  Future<MessageStanza> _pinChatStanza(
    Jid? jid,
    bool isPinned,
    MessageParams additional,
  ) async {
    final stanza = MessageStanza(
        additional.messageId.isEmpty
            ? AbstractStanza.getRandomId()
            : additional.messageId,
        additional.messageType);
    stanza.toJid = jid;
    stanza.fromJid = _connection!.fullJid;
    // Validation
    if (stanza.toJid == null || stanza.fromJid == null) {
      throw InvalidJidMessageStanzaException();
    }

    stanza.addPinChat(jid?.fullJid ?? '', isPinned);

    if (additional.millisecondTs != 0) {
      stanza.addTime(additional.millisecondTs);
    }

    if (additional.customString.isNotEmpty) {
      stanza.addCustom(additional.customString);
    }

    if (additional.chatStateType != ChatStateType.None) {
      ChatStateDecoration(message: stanza).setState(additional.chatStateType);
    }

    // Add receipt delivery
    if (additional.receipt == ReceiptRequestType.RECEIVED) {
      stanza.addReceivedReceipt();
    } else if (additional.receipt == ReceiptRequestType.REQUEST) {
      stanza.addRequestReceipt();
    }

    if (additional.ampMessageType == AmpMessageType.Delivery) {
      // Add request stanza from server?
      stanza.addAmpDeliverDirect();
    }

    await _connection!.writeStanzaWithQueue(stanza);

    return stanza;
    // Could not wait for the ack, there is no ack sent (r, c type)
    // return responseHandler.set<MessageStanza>(stanza.id!, stanza);
  }

  @override
  Future<MessageStanza> quoteMessage(
      Jid to,
      String messageId,
      String body,
      String quoteText,
      String userId,
      String username,
      String? messageType,
      String? expts,
      {MessageParams additional = const MessageParams(
          millisecondTs: 0,
          customString: '',
          messageId: '',
          receipt: ReceiptRequestType.NONE,
          messageType: MessageStanzaType.CHAT,
          chatStateType: ChatStateType.None,
          ampMessageType: AmpMessageType.None,
          options: XmppCommunicationConfig(shallWaitStanza: false),
          hasEncryptedBody: false)}) {
    return _quoteMessageStanza(to, messageId, body, quoteText, userId, username,
        messageType, expts, additional);
  }

  Future<MessageStanza> _quoteMessageStanza(
    Jid? jid,
    String messageId,
    String body,
    String quoteText,
    String userId,
    String username,
    String? messageType,
    String? expts,
    MessageParams additional,
  ) async {
    final stanza = MessageStanza(
        additional.messageId.isEmpty
            ? AbstractStanza.getRandomId()
            : additional.messageId,
        additional.messageType);
    stanza.toJid = jid;
    stanza.fromJid = _connection!.fullJid;
    // Validation
    if (stanza.toJid == null || stanza.fromJid == null) {
      throw InvalidJidMessageStanzaException();
    }

    stanza.body = body;

    stanza.addQuoteMessage(messageId, userId, username);
    stanza.addQuoteCustom(
        messageType ?? 'txt', expts ?? '0', quoteText, username);

    if (additional.millisecondTs != 0) {
      stanza.addTime(additional.millisecondTs);
    }

    if (additional.customString.isNotEmpty) {
      stanza.addCustom(additional.customString);
    }

    if (additional.chatStateType != ChatStateType.None) {
      ChatStateDecoration(message: stanza).setState(additional.chatStateType);
    }

    // Add receipt delivery
    if (additional.receipt == ReceiptRequestType.RECEIVED) {
      stanza.addReceivedReceipt();
    } else if (additional.receipt == ReceiptRequestType.REQUEST) {
      stanza.addRequestReceipt();
    }

    if (additional.ampMessageType == AmpMessageType.Delivery) {
      // Add request stanza from server?
      stanza.addAmpDeliverDirect();
    }

    await _connection!.writeStanzaWithQueue(stanza);

    return stanza;
    // Could not wait for the ack, there is no ack sent (r, c type)
    // return responseHandler.set<MessageStanza>(stanza.id!, stanza);
  }

  @override
  Future<MessageStanza> sendMUCInfoMessage(
    Jid to, {
    String? subject,
    String? coverUrl,
    String? membersAddedEncoded,
    String? membersRemovedEncoded,
    MessageParams additional = const MessageParams(
      millisecondTs: 0,
      customString: '',
      messageId: '',
      receipt: ReceiptRequestType.NONE,
      messageType: MessageStanzaType.CHAT,
      chatStateType: ChatStateType.None,
      ampMessageType: AmpMessageType.None,
      hasEncryptedBody: false,
      options: XmppCommunicationConfig(shallWaitStanza: false),
    ),
  }) {
    return _sendMUCInfoMessageStanza(
      to,
      subject: subject,
      coverUrl: coverUrl,
      additional: additional,
      membersAddedEncoded: membersAddedEncoded,
      membersRemovedEncoded: membersRemovedEncoded,
    );
  }

  Future<MessageStanza> _sendMUCInfoMessageStanza(
    Jid? jid, {
    String? subject,
    String? coverUrl,
    String? membersAddedEncoded,
    String? membersRemovedEncoded,
    required MessageParams additional,
  }) async {
    final stanza = MessageStanza(
        additional.messageId.isEmpty
            ? AbstractStanza.getRandomId()
            : additional.messageId,
        additional.messageType);
    stanza.toJid = jid;
    stanza.fromJid = _connection!.fullJid;
    // Validation
    if (stanza.toJid == null || stanza.fromJid == null) {
      throw InvalidJidMessageStanzaException();
    }

    stanza.addMUCInfo(
      subjectChanged: subject,
      coverUrlChanged: coverUrl,
      membersAddedEncoded: membersAddedEncoded,
      membersRemovedEncoded: membersRemovedEncoded,
    );

    if (additional.millisecondTs != 0) {
      stanza.addTime(additional.millisecondTs);
    }

    if (additional.customString.isNotEmpty) {
      stanza.addCustom(additional.customString);
    }

    if (additional.chatStateType != ChatStateType.None) {
      ChatStateDecoration(message: stanza).setState(additional.chatStateType);
    }

    // Add receipt delivery
    if (additional.receipt == ReceiptRequestType.RECEIVED) {
      stanza.addReceivedReceipt();
    } else if (additional.receipt == ReceiptRequestType.REQUEST) {
      stanza.addRequestReceipt();
    }

    if (additional.ampMessageType == AmpMessageType.Delivery) {
      // Add request stanza from server?
      stanza.addAmpDeliverDirect();
    }

    await _connection!.writeStanzaWithQueue(stanza);

    return stanza;
    // Could not wait for the ack, there is no ack sent (r, c type)
    // return responseHandler.set<MessageStanza>(stanza.id!, stanza);
  }

  @override
  Future<MessageStanza> changeMemberRole(
    Jid to, {
    required String userJid,
    required String role,
    MessageParams additional = const MessageParams(
      millisecondTs: 0,
      customString: '',
      messageId: '',
      receipt: ReceiptRequestType.NONE,
      messageType: MessageStanzaType.CHAT,
      chatStateType: ChatStateType.None,
      ampMessageType: AmpMessageType.None,
      hasEncryptedBody: false,
      options: XmppCommunicationConfig(shallWaitStanza: false),
    ),
  }) {
    return _changeMemberRoleMessageStanza(
      to,
      userJid: userJid,
      role: role,
      additional: additional,
    );
  }

  Future<MessageStanza> _changeMemberRoleMessageStanza(
    Jid? jid, {
    required String userJid,
    required String role,
    required MessageParams additional,
  }) async {
    final stanza = MessageStanza(
        additional.messageId.isEmpty
            ? AbstractStanza.getRandomId()
            : additional.messageId,
        additional.messageType);
    stanza.toJid = jid;
    stanza.fromJid = _connection!.fullJid;
    // Validation
    if (stanza.toJid == null || stanza.fromJid == null) {
      throw InvalidJidMessageStanzaException();
    }

    stanza.changeMemberRole(userJid, role);

    if (additional.millisecondTs != 0) {
      stanza.addTime(additional.millisecondTs);
    }

    if (additional.customString.isNotEmpty) {
      stanza.addCustom(additional.customString);
    }

    if (additional.chatStateType != ChatStateType.None) {
      ChatStateDecoration(message: stanza).setState(additional.chatStateType);
    }

    // Add receipt delivery
    if (additional.receipt == ReceiptRequestType.RECEIVED) {
      stanza.addReceivedReceipt();
    } else if (additional.receipt == ReceiptRequestType.REQUEST) {
      stanza.addRequestReceipt();
    }

    if (additional.ampMessageType == AmpMessageType.Delivery) {
      // Add request stanza from server?
      stanza.addAmpDeliverDirect();
    }

    await _connection!.writeStanzaWithQueue(stanza);

    return stanza;
    // Could not wait for the ack, there is no ack sent (r, c type)
    // return responseHandler.set<MessageStanza>(stanza.id!, stanza);
  }

  @override
  Future<MessageStanza> recallMessage(
      Jid jid, List<String> messageId, String userId,
      {MessageParams additional = const MessageParams(
          millisecondTs: 0,
          customString: '',
          messageId: '',
          receipt: ReceiptRequestType.NONE,
          messageType: MessageStanzaType.CHAT,
          chatStateType: ChatStateType.None,
          ampMessageType: AmpMessageType.None,
          options: XmppCommunicationConfig(shallWaitStanza: false),
          hasEncryptedBody: false)}) {
    return _recallMessageStanza(jid, messageId, userId, additional);
  }

  Future<MessageStanza> _recallMessageStanza(
    Jid? jid,
    List<String> messageId,
    String userId,
    MessageParams additional,
  ) async {
    final stanza = MessageStanza(
        additional.messageId.isEmpty
            ? AbstractStanza.getRandomId()
            : additional.messageId,
        additional.messageType);
    stanza.toJid = jid;
    stanza.fromJid = _connection!.fullJid;
    // Validation
    if (stanza.toJid == null || stanza.fromJid == null) {
      throw InvalidJidMessageStanzaException();
    }
    stanza.addRecallMessage(userId, messageId.join(','));

    if (additional.millisecondTs != 0) {
      stanza.addTime(additional.millisecondTs);
    }

    if (additional.customString.isNotEmpty) {
      stanza.addCustom(additional.customString);
    }

    if (additional.chatStateType != ChatStateType.None) {
      ChatStateDecoration(message: stanza).setState(additional.chatStateType);
    }

    // Add receipt delivery
    if (additional.receipt == ReceiptRequestType.RECEIVED) {
      stanza.addReceivedReceipt();
    } else if (additional.receipt == ReceiptRequestType.REQUEST) {
      stanza.addRequestReceipt();
    }

    if (additional.ampMessageType == AmpMessageType.Delivery) {
      // Add request stanza from server?
      stanza.addAmpDeliverDirect();
    }

    await _connection!.writeStanzaWithQueue(stanza);

    return stanza;
    // Could not wait for the ack, there is no ack sent (r, c type)
    // return responseHandler.set<MessageStanza>(stanza.id!, stanza);
  }
}
