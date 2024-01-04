import 'package:xmpp_stone/xmpp_stone.dart';

class XMPPClientPersonal {
  String jid;
  String password;
  VCard? profile;
  List<Buddy>? buddies;
  List<GroupChatroom>? groups;
  XMPPClientPersonal(this.jid, this.password);
}
