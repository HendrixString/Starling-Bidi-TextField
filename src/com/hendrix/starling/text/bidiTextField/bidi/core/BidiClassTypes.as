package com.hendrix.starling.text.bidiTextField.bidi.core
{
  public class BidiClassTypes
  {
    /**
     * Left-to-Right<br>
     * Most alphabetic and syllabic characters, Han ideographs, non-European or non-Arabic digits, LRM character, ... 
     */
    static public var L:          String = "L";
    /**
     * Right-to-Left Embedding  <br>
     * LRE character only 
     */
    static public var LRE:        String = "LRE";
    /**
     * Left-to-Right Override <br>
     * LRO character only  
     */
    static public var LRO:        String = "LRO";
    /**
     * Right-to-Left  <br>
     * Hebrew alphabet and related punctuation, RLM character  
     */
    static public var R:          String = "R";
    /**
     * Right-to-Left Arabic <br>
     * Arabic, Thaana and Syriac alphabets, and most punctuation specific to those scripts   
     */
    static public var AL:         String = "AL";
    /**
     * Right-to-Left Embedding  <br>
     * RLE character only  
     */
    static public var RLE:        String = "RLE";
    /**
     * Right-to-Left Override <br>
     * RLO character only  
     */
    static public var RLO:        String = "RLO";
    /**
     * Pop Directional Format <br>
     * PDF character only  
     */
    static public var PDF:        String = "PDF";
    /**
     * European Number  <br>
     * European digits, Eastern Arabic-Indic digits, ...   
     */
    static public var EN:         String = "EN";
    /**
     * European Separator <br>
     * plus sign, minus sign, ...  
     */
    static public var ES:         String = "ES";
    /**
     * European Number Terminator <br>
     * degree sign, currency symbols, ...  
     */
    static public var ET:         String = "ET";
    /**
     * Arabic Number  <br>
     * Arabic-Indic digits, Arabic decimal and thousands separators, ...   
     */
    static public var AN:         String = "AN";
    /**
     * Common Number Separator  <br>
     * colon, comma, full stop, no-break space, ...  
     */
    static public var CS:         String = "CS";
    /**
     * Nonspacing Mark  <br>
     * Characters in General Categories Mark, nonspacing and Mark, enclosing (Mn, Me)  
     */
    static public var NSM:        String = "NSM";
    /**
     * Boundary Neutral <br>
     * Default ignorables, non-characters, control characters other than those explicitly given other types  
     */
    static public var BN:         String = "BN";
    /**
     * Paragraph Separator  <br>
     * paragraph separator, appropriate Newline Functions, higher-level protocol paragraph determination   
     */
    static public var B:          String = "B";
    /**
     * Segment Separator  <br>
     * Tab 
     */
    static public var S:          String = "S";
    /**
     * Whitespace<br>
     * space, figure space, line separator, form feed, General Punctuation block spaces  
     */
    static public var WS:         String = "WS";
    /**
     * Other Neutrals <br>
     * All other characters, including object replacement character  
     */
    static public var ON:         String = "ON";
    
    public function BidiClassTypes()
    {
    }
  }
}