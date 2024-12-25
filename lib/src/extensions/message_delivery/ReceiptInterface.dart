import 'package:xmpp_stone/xmpp_stone.dart';

enum ReceiptRequestType { NONE, REQUEST, RECEIVED }

abstract class ReceiptInterface {
  ReceiptInterface addRequestReceipt();
  ReceiptInterface addReceivedReceipt(String id);
  XmppElement? getRequestReceipt();
  XmppElement? getReceivedReceipt();
}
