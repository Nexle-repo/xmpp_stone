import 'package:tuple/tuple.dart';
import 'package:xmpp_stone/src/data/Jid.dart';
import 'package:xmpp_stone/src/elements/XmppAttribute.dart';
import 'package:xmpp_stone/src/elements/XmppElement.dart';
import 'package:xmpp_stone/src/elements/encryption/EncryptHeaderElement.dart';
import 'package:xmpp_stone/src/elements/encryption/EncryptKeyElement.dart';
import 'package:xmpp_stone/src/elements/encryption/EncryptKeysElement.dart';
import 'package:xmpp_stone/src/elements/encryption/EncryptPayloadElement.dart';
import 'package:xmpp_stone/src/extensions/omemo/OMEMOParams.dart';

class EncryptElement extends XmppElement {
  static String elementName = 'encrypted';
  EncryptElement() {
    name = elementName;
  }

  EncryptElement.build({
    required EncryptHeaderElement header,
    required EncryptPayloadElement payload,
  }) {
    name = EncryptElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:omemo:2'));
    addChild(header);
    addChild(payload);
  }
  static Tuple2<XmppElement, OMEMOEnvelopeEncryptionParams>? parseEncryption(
      parent) {
    try {
      final _encryptElement = parent.children.firstWhere(
          (child) => (child.name == EncryptElement.elementName),
          orElse: () => null);
      if (_encryptElement == null) {
        return null;
      }
      final _headerElement = EncryptHeaderElement.parse(_encryptElement);

      if (_headerElement == null) {
        return null;
      }
      final _payloadElement = EncryptPayloadElement.parse(_encryptElement);

      final keysElement = _headerElement.children
          .where((element) => element!.name == EncryptKeysElement.elementName);
      final List<EncryptKeysElement> keysList = [];

      final List<OMEMORecipientInfo> recipientInfo = [];

      keysElement.forEach((keys) {
        List<EncryptKeyElement> keyList = [];
        List<OMEMORecipientDeviceInfo> recipientKeysInfo = [];
        keys!.children
            .where((element) => element!.name == EncryptKeyElement.elementName)
            .forEach((key) {
          final deviceId = key!.getAttribute('rid')!.value!;
          final isKeyExchange = key.getAttribute('kex') != null &&
              key.getAttribute('kex')!.value! == 'true';
          final encoded = key.textValue!;
          keyList.add(EncryptKeyElement.build(
              rid: deviceId, keyExchange: isKeyExchange, encoded: encoded));

          recipientKeysInfo.add(OMEMORecipientDeviceInfo(
              deviceId: deviceId,
              keyExchange: isKeyExchange,
              encoded: encoded));
        });
        final recipient = Jid.fromFullJid(keys.getAttribute('jid')!.value!);
        keysList.add(
            EncryptKeysElement.build(to: recipient, recipientKeys: keyList));

        recipientInfo.add(OMEMORecipientInfo(
            recipientJid: recipient, recipientKeysInfo: recipientKeysInfo));
      });
      final senderDeviceId = _headerElement.getAttribute('sid')!.value!;
      final cipherPayload =
          _payloadElement!.textValue == null ? '' : _payloadElement.textValue!;
      final EncryptHeaderElement header = EncryptHeaderElement.build(
          senderDeviceId: senderDeviceId, recipientKeysList: keysList);
      final EncryptElement encryptElement = EncryptElement.build(
        header: header,
        payload: EncryptPayloadElement.build(cipherText: cipherPayload),
      );

      final OMEMOEnvelopeEncryptionParams params =
          OMEMOEnvelopeEncryptionParams(
              cipherText: cipherPayload,
              recipientInfo: recipientInfo,
              senderDeviceId: senderDeviceId);

      return Tuple2<XmppElement, OMEMOEnvelopeEncryptionParams>(
          encryptElement, params);
    } catch (e) {
      return null;
    }
  }

  static XmppElement? parseElement(parent) {
    try {
      return parseEncryption(parent)!.item1;
    } catch (e) {
      return null;
    }
  }

  static OMEMOEnvelopeEncryptionParams? parseParams(parent) {
    try {
      return parseEncryption(parent)!.item2;
    } catch (e) {
      return null;
    }
  }
}
