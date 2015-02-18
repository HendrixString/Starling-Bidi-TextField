package com.hendrix.starling.text.bidiTextField.bidi
{
  import com.hendrix.starling.text.bidiTextField.bidi.core.db.BidiClassDB;
  
  /**
   * the bidi service class. a Singleton 
   * @author Tomer Shalev
   * 
   */
  public class Bidi
  {
    static private var _instance: Bidi = null; 
    
    /**
     * map Unicode characters to bidi Classes 
     */
    private var _mapUCtoBDC:      BidiClassDB;
    /**
     * the Bidi implementation 
     */
    private var _bidiFactory:     BidiFactory;
    
    public static function get instance():Bidi
    {
      return (_instance == null) ? new Bidi() : _instance;
    }
    
    public function Bidi()
    {
      if(_instance != null)
        throw new Error("Singleton!!!!");
      
      _instance     = this;   
      _mapUCtoBDC   = new BidiClassDB();
      
      _mapUCtoBDC.loadDataBaseFromFile();
      
      _bidiFactory  = new BidiFactory(_mapUCtoBDC);
    }
    
    /**
     * perform bidi on a string 
     * @param input the input string
     * @param bidiLevel thy level (direction) of the string
     * @return the transformed string
     * 
     */
    public function bidiMe(input:String, bidiLevel:uint = 0):String
    {
      _bidiFactory.paragraphEmbeddingLevel  = bidiLevel;
      _bidiFactory.textinput                = input;
      _bidiFactory.startBidi();
      
      return _bidiFactory.textinput;
    }
    
    /**
     * perform the actual reordering step after resolution has been setup 
     * @param sBoundIndex start index
     * @param eBoundIndex end index
     * @return a resolved atring
     * 
     */
    public function reorderLineSegment(sBoundIndex:uint = 0, eBoundIndex:int = -1):String
    {
      return _bidiFactory.reorderResolvedLevels(sBoundIndex, eBoundIndex);
    }
    
  }
  
}