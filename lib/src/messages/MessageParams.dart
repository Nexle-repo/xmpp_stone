import 'package:xmpp_stone/src/access_point/communication_config.dart';
import 'package:xmpp_stone/src/elements/stanzas/MessageStanza.dart';
import 'package:xmpp_stone/src/extensions/advanced_messaging_processing/AmpManager.dart';
import 'package:xmpp_stone/src/extensions/chat_states/ChatStateDecoration.dart';
import 'package:xmpp_stone/src/extensions/message_delivery/ReceiptInterface.dart';

class MessageParams {
  final ReceiptRequestType receipt; // = ReceiptRequestType.NONE;
  final String messageId;
  final int millisecondTs;
  final String customString;
  final String? customId;
  final MessageStanzaType messageType; // = MessageStanzaType.CHAT;
  final XmppCommunicationConfig options;
  final ChatStateType chatStateType;
  final AmpMessageType ampMessageType;
  final bool hasEncryptedBody;

  const MessageParams({
    required this.receipt,
    required this.messageId,
    required this.millisecondTs,
    required this.customString,
    required this.messageType,
    required this.options,
    required this.chatStateType,
    required this.ampMessageType,
    required this.hasEncryptedBody,
    this.customId,
  });

  static const MessageParams defaultMessageParams = MessageParams(
      millisecondTs: 0,
      customString: '',
      messageId: '',
      customId: '',
      receipt: ReceiptRequestType.RECEIVED,
      messageType: MessageStanzaType.CHAT,
      chatStateType: ChatStateType.None,
      ampMessageType: AmpMessageType.None,
      options: XmppCommunicationConfig(shallWaitStanza: false),
      hasEncryptedBody: false);

  static MessageParams build({
    ReceiptRequestType receipt = ReceiptRequestType.NONE,
    String messageId = '',
    int millisecondTs = 0,
    String customString = '',
    String customId = '',
    MessageStanzaType messageType = MessageStanzaType.CHAT,
    ChatStateType chatStateType = ChatStateType.None,
    AmpMessageType ampMessageType = AmpMessageType.None,
    XmppCommunicationConfig options =
        const XmppCommunicationConfig(shallWaitStanza: false),
    bool hasEncryptedBody = false,
  }) {
    return MessageParams(
      receipt: receipt,
      messageId: messageId,
      customId: customId,
      millisecondTs: millisecondTs,
      customString: customString,
      messageType: messageType,
      options: options,
      chatStateType: chatStateType,
      ampMessageType: ampMessageType,
      hasEncryptedBody: hasEncryptedBody,
    );
  }
}
