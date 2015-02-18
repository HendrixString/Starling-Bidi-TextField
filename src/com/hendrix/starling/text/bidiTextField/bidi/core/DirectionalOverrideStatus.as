package com.hendrix.starling.text.bidiTextField.bidi.core
{
  public class DirectionalOverrideStatus
  {
    /**
     * No override is currently active 
     */
    static public var Neutral:        String = "Neutral";
    /**
     * Characters are to be reset to R 
     */
    static public var Right_To_Left:  String = "Right_To_Left";
    /**
     * Characters are to be reset to L 
     */
    static public var Left_To_Right:  String = "Left_To_Right";
    
    public function DirectionalOverrideStatus()
    {
    }
  }
}