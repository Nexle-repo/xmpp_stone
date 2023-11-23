import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class ExampleCustomElement extends XmppElement {
  static String elementName = 'custom';
  ExampleCustomElement() {
    name = elementName;
  }

  ExampleCustomElement.buildQuote(
      String type, String expts, String text, String refMsgTitle) {
    name = ExampleCustomElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'rhp:urn:example:custom'));
    addAttribute(XmppAttribute('type', type));
    addAttribute(XmppAttribute('refMsgTitle', refMsgTitle));
    addAttribute(XmppAttribute('refMsgBody', text));
    addAttribute(XmppAttribute('expts', expts));
    textValue = '';
  }

  ExampleCustomElement.addCustom() {
    name = ExampleCustomElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'rhp:urn:example:custom'));
    addAttribute(XmppAttribute('expts', "0"));
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == ExampleCustomElement.elementName),
        orElse: () => null);
  }
}
