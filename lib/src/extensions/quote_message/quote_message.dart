class QuoteMessage {
  final String refMsgId;
  final String refMsgShortDesc;
  final String refMsgType;
  final int refUserId;
  final String refUsername;
  final String refMsgTitle;
  QuoteMessage({
    required this.refMsgId,
    required this.refUserId,
    required this.refMsgShortDesc,
    required this.refMsgType,
    required this.refUsername,
    required this.refMsgTitle
  });
}