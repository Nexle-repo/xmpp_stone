import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class ExampleCustomElement extends XmppElement {
  static String elementName = 'custom';
  ExampleCustomElement() {
    name = elementName;
  }

  ExampleCustomElement.buildQuote(String type, String expts, String text) {
    name = ExampleCustomElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'rhp:urn:example:custom'));
    addAttribute(XmppAttribute('type', type));
    addAttribute(XmppAttribute('expts', expts));
    textValue = text;
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == ExampleCustomElement.elementName),
        orElse: () => null);
  }
}
