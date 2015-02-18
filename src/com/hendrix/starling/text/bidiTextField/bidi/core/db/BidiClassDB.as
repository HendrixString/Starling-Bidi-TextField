package com.hendrix.starling.text.bidiTextField.bidi.core.db
{
  import flash.filesystem.File;
  import flash.filesystem.FileMode;
  import flash.filesystem.FileStream;
  import flash.utils.ByteArray;
  import flash.utils.Dictionary;
  
  /**
   * the BIDI database 
   * @author Tomer Shalev
   * 
   */
  public class BidiClassDB
  {
    private var _mapCodeToBidiClass:  Dictionary = null;
    private var _mapUCtoMirroredUC:   Dictionary = null;
    
    public function BidiClassDB()
    {
      _mapCodeToBidiClass = new Dictionary();
      _mapUCtoMirroredUC  = new Dictionary();
      
      loadDataBaseFromFile();
    }
    
    public function UCtoBidiClass(unicode:uint):String
    {
      return _mapCodeToBidiClass[unicode];
    }
    
    public function UCtoMirroredUC(unicode:uint):Number
    {
      return _mapUCtoMirroredUC[unicode];
    }
    
    public function loadDataBaseFromFile():void
    {
      var bd:String = (new SResources.uniformCodeDataBase() as ByteArray).toString();
      parseBidiClassCSV(bd);
      
      bd = (new SResources.bidiMirroringDataBase() as ByteArray).toString();
      parseBidiMirrorCSV(bd);
    }
    
    private function parseBidiMirrorCSV($bd:String):void
    {
      var lines:        Array                 = $bd.split("\r\n");
      
      var linesCount:   uint                  = lines.length;
      var line:         Array;
      var unicodeFrom:  Number;
      var unicodeTo:    Number;
      
      for(var ix:uint = 0; ix < linesCount; ix++) 
      {
        line                                  = (lines[ix] as String).split(";");
        unicodeFrom                           = Number("0x" + line[0]);
        var d:String = (line[1] as String).split(" ")[1];
        unicodeTo                             = Number("0x" + (line[1] as String).split(" ")[1]);
        
        _mapUCtoMirroredUC[unicodeFrom]       = unicodeTo;
        
      }
      
    }
    
    private function parseBidiClassCSV($bd:String):void
    {
      var lines:      Array                 = $bd.split("\r\n");
      
      var linesCount: uint                  = lines.length;
      var line:       Array;
      var unicode:    Number;
      
      for(var ix:uint = 0; ix < linesCount; ix++) 
      {
        line                                = (lines[ix] as String).split(";");
        unicode                             = Number("0x" + line[0]);
        
        _mapCodeToBidiClass[unicode]        = String(line[4]);
        
      }
      
    }
    
    public static function readTextfile(path: Object): String
    {
      var file: File;
      if (path is File)
        file = path as File;
      else if (path is String)
        file = new File(String(path));
      else throw new Error("SFile.readTextFile() - path is not a File object or String.");
      
      var text: String = "";
      if (file.exists == false)
        throw new Error("SFile.readTextFile() - file does not exist" +  file);
      
      if (file.exists && (file.size > 0))
      {
        var fs: FileStream = new FileStream();
        try {
          fs.open(file, FileMode.READ);
          text = fs.readUTFBytes(file.size);
          fs.close();
        }
        catch (err: Error) {
          // what to do...
          new Error("SFile.readTextFile() - file could not be opened/read.");
        }
      }
      
      return text;
    }
    
  }
  
}