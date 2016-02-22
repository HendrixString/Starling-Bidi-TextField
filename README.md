# Starling-Bidi-TextField
Bidirectional Bitmap Font TextField control for Starling

## How to use
simply fork or download the project, you can also download the binary itself and link it
to your project, or import to your IDE of choice such as `Flash Builder 4.7`. requires `Starling` framework.

## Features
- now you can use Bidirectional text with bitmap fonts in stage3d.
- full implementation of the `UNICODE BIDIRECTIONAL ALGORITHM` revision 31.
- supports text truncation.
- supports text truncation.

## Guide

```actionscript
[Embed(source="assets/fonts/bf/arr.fnt", mimeType="application/octet-stream")]
public static const FontXml:Class;

[Embed(source = "assets/fonts/bf/arr_0.png")]
public static const FontTexture:Class;

protected function init(): void
{
  var text:String           = 'טקסט בשפה עברית. טקסט בשפה עברית 12345 טקסט בשפה אנגלית hello world שלום עולם';
  
  var texture:  Texture     = Texture.fromBitmap(new FontTexture(), false);
  var xml:      XML         = XML(new FontXml());
  
  BidiTextField.registerBitmapFont(new BidiBitmapFont(texture,xml), "ArialBD");
  
  var tfBidi: BidiTextField = new BidiTextField(1, 1, "", "ArialBD");
  tfBidi.fontSize           = 20;
  tfBidi.isTrancted         = true;
  tfBidi.bidiLevel          = 1;
  tfBidi.color              = 0x00;
  tfBidi.hAlign             = HAlign.RIGHT;
  tfBidi.vAlign             = VAlign.TOP;
  tfBidi.width              = width;
  tfBidi.height             = 200;

  tfBidi.text               = text;
  
  addChild(tfBidi);
}

```

### Dependencies
* [`Starling-Framework`](https://github.com/Gamua/Starling-Framework)

### Terms
* completely free source code. [Apache License, Version 2.0.](http://www.apache.org/licenses/LICENSE-2.0)
* if you like it -> star or share it with others

### Contact Author
* [tomer.shalev@gmail.com](tomer.shalev@gmail.com)
* [Google+ TomershalevMan](https://plus.google.com/+TomershalevMan/about)
* [Facebook - HendrixString](https://www.facebook.com/HendrixString)
