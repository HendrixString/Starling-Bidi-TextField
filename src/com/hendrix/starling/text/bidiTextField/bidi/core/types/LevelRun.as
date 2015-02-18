package com.hendrix.starling.text.bidiTextField.bidi.core.types
{
  /**
   * a data structure describing a level run
   * @author Tomer Shalev
   * 
   */
  public class LevelRun
  {
    public var startIndex:  uint;
    public var EndIndex:    uint;
    
    public var level:       uint;
    
    public var sorLevel:    uint;
    public var sorType:     String;
    public var eorType:     String;
    public var eorLevel:    uint;
    
    public function LevelRun()
    {
    }
  }
}