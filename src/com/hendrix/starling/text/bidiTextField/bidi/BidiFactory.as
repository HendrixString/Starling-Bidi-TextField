package com.hendrix.starling.text.bidiTextField.bidi
{
  import com.hendrix.starling.text.bidiTextField.bidi.core.BidiClassTypes;
  import com.hendrix.starling.text.bidiTextField.bidi.core.DirectionalOverrideStatus;
  import com.hendrix.starling.text.bidiTextField.bidi.core.db.BidiClassDB;
  import com.hendrix.starling.text.bidiTextField.bidi.core.types.LevelRun;
  
  /**
   * the Bidirectional algorithm implementation <br>
   * as outlined at http://unicode.org/reports/tr9/
   * @author Tomer Shalev
   * 
   */
  public class BidiFactory
  {
    static public const MAX_EMBEDDING_LEVEL:      uint = 61;
    
    private var _textinput:                       String;
    private var _textOutput:                      Vector.<String>;
    private var _textAux:                         Vector.<String>;
    
    private var _charsDirections:                 String;
    private var _charsLevels:                     Vector.<uint>;
    private var _charsTypes:                      Vector.<String>;
    
    private var _bcdb:                            BidiClassDB;
    
    private var _paragraphEmbeddingLevel:         uint;
    private var _currentEmbeddingLevel:           uint;
    private var _directionalOverrideStatus:       String;
    
    private var _stackEmbeddingLevel:             Vector.<uint>;
    private var _stackDirectionalOverrideStatus:  Vector.<String>;
    
    private var _levelRuns:                       Vector.<LevelRun> = null;
    private var _countLevelRuns:                  uint              = 0;
    
    private var _auxString:                       String            = new String();
    
    //optimizations
    private var _applyRuleW5:                     Boolean           = true;
    
    static private const RLE:                     uint              = 0x202B;
    static private const LRE:                     uint              = 0x202A;
    static private const RLO:                     uint              = 0x202E;
    static private const LRO:                     uint              = 0x202D;
    static private const LRM:                     uint              = 0x200E;
    static private const RLM:                     uint              = 0x200F;
    
    /**
     * the Bidirectional algorithm implementation <br>
     * as outlined at http://unicode.org/reports/tr9/
     * @param $bcdb the database
     * 
     */
    public function BidiFactory($bcdb:BidiClassDB)
    {
      _bcdb                           = $bcdb;
      
      _textOutput                     = new Vector.<String>();
      _textAux                        = new Vector.<String>();
      
      _charsTypes                     = new Vector.<String>(5000);
      _charsDirections                = new String();
      _charsLevels                    = new Vector.<uint>();
      
      _levelRuns                      = new Vector.<LevelRun>();
      
      // pool
      for(var ix:uint = 0; ix < 200; ix++)
        _levelRuns.push(new LevelRun());
      
      _stackEmbeddingLevel            = new Vector.<uint>();
      _stackDirectionalOverrideStatus = new Vector.<String>();
    }
    
    public function startBidi():void
    {
      if(_textinput.length == 0)
        return;
      
      reset();
      explicitLevelsAndDirections();
      computeLevelRuns();
      resolveWeakTypes();
      resolveNeutralTypes();
      resolveImplicitLevels();
      computeLevelRuns();
      //printOutput();
      //reorderResolvedLevels();
      //trace();
    }
    
    /**
     * 
     */
    
    private function reset():void
    {
      _applyRuleW5                            = true;
      _countLevelRuns                         = 0;
      _stackEmbeddingLevel.length             = 0;
      _stackDirectionalOverrideStatus.length  = 0;
      
    }
    
    private function printOutput():void
    {
      for(var ix:uint = 0; ix < _charsLevels.length; ix++)
      {
        trace("(" + _charsTypes[ix] + "," + _charsLevels[ix] + ") ");
      }
    }
    
    private function computeMaxLevelInDomain(sBoundIndex:uint = 0, eBoundIndex:int = -1):uint
    {
      var max:  uint                  = 0;
      
      eBoundIndex                     = (eBoundIndex == -1) ? _textinput.length : eBoundIndex;
      
      var flagLevelRunIntersectsDomain:Boolean = false;
      
      for(var ix:uint = 0;  ix < _countLevelRuns; ix++)
      {
        flagLevelRunIntersectsDomain  = !((_levelRuns[ix].EndIndex < sBoundIndex) || (_levelRuns[ix].startIndex > eBoundIndex));
        max                           = Math.max(max, flagLevelRunIntersectsDomain ? _levelRuns[ix].level : 0); 
      }
      
      return max;
    }
    
    public function reorderResolvedLevels(sBoundIndex:uint = 0, eBoundIndex:int = -1):String
    {
      var lr:LevelRun;
      
      eBoundIndex           = (eBoundIndex == -1) ? _textinput.length : eBoundIndex + 0;
      
      var maxLevel:uint     = computeMaxLevelInDomain(sBoundIndex, eBoundIndex); //max level should be computed efficiently with binary search
      var currentLevel:uint = maxLevel;
      
      var flagLevelRunIntersectsDomain:Boolean = false;
      
      var sIndex:int = -1;
      var eIndex:int = -1;
      
      //trace("**********************************************************************************************"+maxLevel)
      
      for(var ix:int = maxLevel; ix >= 1; ix--)
      {
        currentLevel = ix;
        
        sIndex = -1;
        eIndex = -1;
        
        for(var kx:uint = 0; kx < _countLevelRuns; kx++)
        {
          lr = _levelRuns[kx];
          
          flagLevelRunIntersectsDomain = !((_levelRuns[kx].EndIndex < sBoundIndex) || (_levelRuns[kx].startIndex > eBoundIndex));
          
          if(flagLevelRunIntersectsDomain == false)
            continue;
          
          if(lr.level >= currentLevel)
          {
            if(sIndex == -1)
              sIndex = Math.max(lr.startIndex, sBoundIndex);
            eIndex = Math.min(lr.EndIndex, eBoundIndex);
          }
          else if(lr.level < currentLevel)
          {
            if((sIndex >= 0) && (eIndex >= 0))
            {
              reverse(sIndex, eIndex);  
            }
            
            sIndex = -1;
            eIndex = -1;
          }
          else
          {
            continue;
          }
          
          
        }
        
        if((sIndex >= 0) && (eIndex >= 0))
        {
          reverse(sIndex, eIndex);  
        }
        
      }
      
      var len:uint = _textinput.length;
      
      _auxString = "";
      
      //this to change
      var mirrored:Number;
      
      for(ix = sBoundIndex; ix < eBoundIndex; ix++) 
      {
        mirrored = _bcdb.UCtoMirroredUC( _textOutput[ix].charCodeAt(0) );
        
        if( !isNaN(mirrored) && _charsTypes[ix] == BidiClassTypes.R )
          _auxString += String.fromCharCode(mirrored);
        else
          _auxString += _textOutput[ix];
        
      }
      
      return _auxString;
      //trace();
    }
    
    private function reverse(sIndex:uint, eIndex:uint):void
    {
      //return $str;
      var resReverse: String  = _auxString;//$auxString ? $auxString : new String();
      resReverse              = "";
      
      for(var ux:int  = eIndex - 1; ux >= sIndex; ux--) {
        _textAux[-ux + eIndex - 1] = _textOutput[ux - 0];
      }
      
      var op:String = "";
      
      for(ux  = sIndex; ux < eIndex; ux++)
      {
        _textOutput[ux] = _textAux[ux - sIndex];
        op+=_textOutput[ux];
      }
      
      //trace(op);
      //trace();
    }
    
    
    private function computeMaxLevel():uint
    {
      var max:uint = 0;
      
      for(var ix:uint = 0;  ix < _countLevelRuns; ix++)
      {
        max  = Math.max(max, _levelRuns[ix].level); 
      }
      
      return max;
    }
    
    private function resolveImplicitLevels():void
    {
      var charCount:uint = _textinput.length;
      var charType:String;
      
      for(var ix:uint = 0; ix < charCount; ix++)
      {
        charType = _charsTypes[ix];
        
        if(isIgnoredChar(charType))
          continue;
        
        // Even level
        if(_charsLevels[ix]%2 == 0)
        {
          if(charType == BidiClassTypes.R)
            _charsLevels[ix] += 1;
          else if((charType == BidiClassTypes.EN) || (charType == BidiClassTypes.AN))
            _charsLevels[ix] += 2;
        }
        else // odd levels
        {
          if((charType == BidiClassTypes.L) || (charType == BidiClassTypes.EN) || (charType == BidiClassTypes.AN))
            _charsLevels[ix] += 1;
        }
      }
    }
    
    /**
     * detects one of the char types that should have been deleted in step X9 
     */
    private function isIgnoredChar(type:String):Boolean
    {
      if( (type == BidiClassTypes.RLE) ||
        (type == BidiClassTypes.LRE) ||
        (type == BidiClassTypes.RLO) ||
        (type == BidiClassTypes.LRO) ||
        (type == BidiClassTypes.PDF) ||
        (type == BidiClassTypes.BN))
        return true
      
      return false;
    }
    
    private function computeLevelRuns():void
    {
      var charCount:uint = _textinput.length;
      var charType:String;
      var lr:LevelRun;
      var currentRunLevel:int = -1;
      
      _countLevelRuns = 0;
      
      for(var ix:uint = 0; ix < charCount; ix++)
      {
        charType = _charsTypes[ix];
        
        if(isIgnoredChar(charType))
          continue;
        
        if(currentRunLevel != _charsLevels[ix]) {
          lr                      = _levelRuns[_countLevelRuns];
          
          lr.level                = _charsLevels[ix];
          lr.sorLevel             = Math.max(lr.level, (_countLevelRuns > 1) ? _levelRuns[_countLevelRuns - 1].level : _paragraphEmbeddingLevel);
          lr.sorType              = levelToType(lr.sorLevel); // L or R
          currentRunLevel         = _charsLevels[ix];
          lr.startIndex           = ix;
          
          if(_countLevelRuns >= 1)
          {
            _levelRuns[_countLevelRuns - 1].EndIndex = ix;
            _levelRuns[_countLevelRuns - 1].eorLevel = lr.sorLevel;
            _levelRuns[_countLevelRuns - 1].eorType = levelToType(lr.sorLevel);
            
          }
          
          _countLevelRuns++;
          
        }
        
      }
      
      lr.EndIndex = ix;
      lr.eorLevel = Math.max(lr.level, _paragraphEmbeddingLevel);
      lr.eorType = levelToType(lr.eorLevel);
      
      //trace();
    }
    
    /**
     * if (-1) is returned use this result to do eor
     */
    private function getNextStrongIndexInRun(levelRun:LevelRun, currentIndex:uint):int
    {
      var charCode:Number;
      var charCodeType:String;
      
      currentIndex = Math.min(currentIndex + 1, levelRun.EndIndex);
      
      for(var ix:uint = currentIndex; ix < levelRun.EndIndex; ix++)
      {
        charCodeType            = _charsTypes[ix];
        
        if(isIgnoredChar(charCodeType))
          continue;
        
        if(isStrongType(charCodeType))
          return ix;
        
      }
      
      return (-1);
    }
    
    private function getPrevStrongIndexInRun(levelRun:LevelRun, currentIndex:uint):int
    {
      var charCode:Number;
      var charCodeType:String;
      
      currentIndex = Math.max(currentIndex - 1, levelRun.startIndex);
      
      for(var ix:uint = currentIndex; ix >= levelRun.startIndex; ix--)
      {
        charCodeType            = _charsTypes[ix];
        
        if(isIgnoredChar(charCodeType))
          continue;
        
        if(isStrongType(charCodeType))
          return ix;
        
      }
      
      return (-1);
    }
    
    private function resolveNeutralTypes():void
    {
      var textLength:uint = _textinput.length;
      var charCode:Number;
      var charCodeType:String;
      
      var currentRunLastStrongType:String = "";
      
      var levelRunsCount:uint = _countLevelRuns;
      
      var clr:LevelRun;
      
      var nextStrongIndexInRun:int = -1;
      var nextStrongTypeInRun:String;
      
      // N 1
      for(var kx:uint = 0; kx < levelRunsCount; kx++)
      {
        clr = _levelRuns[kx];
        currentRunLastStrongType = clr.sorType;
        for(var ix:uint = clr.startIndex; ix < clr.EndIndex; ix++)
        {
          
          charCode                = _textinput.charCodeAt(ix);
          charCodeType            = _charsTypes[ix];//_bcdb.UCtoBidiClass(charCode);
          
          // X9 rule
          if(isIgnoredChar(charCodeType))
            continue;
          
          
          if(isNeutralType(charCodeType))
          {
            var prevTypeInRun:String = getPrevTypeInRun(ix,clr);
            
            // get the index of the next strong in the level run
            if(nextStrongIndexInRun <= ix) {
              nextStrongIndexInRun = getNextStrongIndexInRun(clr, ix);
              nextStrongTypeInRun = (nextStrongIndexInRun == -1) ? clr.eorType : _charsTypes[nextStrongIndexInRun]; 
            }
            
            
            if((prevTypeInRun == BidiClassTypes.L) && (nextStrongTypeInRun == BidiClassTypes.L)){
              _charsTypes[ix] = BidiClassTypes.L;
            }
            else if(  ( (prevTypeInRun == BidiClassTypes.R) || (prevTypeInRun == BidiClassTypes.AN) || (prevTypeInRun == BidiClassTypes.EN)) && 
              ( (nextStrongTypeInRun == BidiClassTypes.R) || (nextStrongTypeInRun == BidiClassTypes.AN) || (nextStrongTypeInRun == BidiClassTypes.EN) )   )
            {
              _charsTypes[ix] = BidiClassTypes.R;
            }
            else {
              _charsTypes[ix] = levelToType(_charsLevels[ix]);
            }
          }
          
          
        }
      }
    }
    
    private function isNeutralType(type:String):Boolean
    {
      if( (type == BidiClassTypes.B)  ||
        (type == BidiClassTypes.S)  ||
        (type == BidiClassTypes.WS) ||
        (type == BidiClassTypes.ON))
        return true;
      return false;
    }
    
    private function resolveWeakTypes():void
    {
      var textLength:uint = _textinput.length;
      var charCode:Number;
      var charCodeType:String;
      
      var prevCharTypeInRun:String;
      var nextCharTypeInRun:String;
      
      //printOutput();
      
      var currentRunLastStrongType:String = "";
      
      // W1 - W4
      // optimize for  non embedding
      var levelRunsCount:uint = _countLevelRuns;
      
      var clr:LevelRun;
      
      //trace();
      
      for(var kx:uint = 0; kx < levelRunsCount; kx++)
      {
        clr = _levelRuns[kx];
        currentRunLastStrongType = clr.sorType;
        for(var ix:uint = clr.startIndex; ix < clr.EndIndex; ix++)
        {
          
          charCode                = _textinput.charCodeAt(ix);
          charCodeType            = _charsTypes[ix];
          
          // X9 rule
          if(isIgnoredChar(charCodeType))
            continue;
          
          // keep track of last seen strong types in the run
          // this helps us to avoid re running on the entire run in the original
          // rule W3 as was defined in the original algorithm
          if(isStrongType(charCodeType))
            currentRunLastStrongType = charCodeType;
          
          // W1
          if(charCodeType == BidiClassTypes.NSM) 
          {
            if(ix == clr.startIndex)
              _charsTypes[ix] = clr.sorType;
            else
              _charsTypes[ix] = _charsTypes[ix - 1];
            continue;
          }
          
          // W2
          if(charCodeType == BidiClassTypes.EN) 
          {
            if(currentRunLastStrongType == BidiClassTypes.AL)
              _charsTypes[ix] = BidiClassTypes.AN;
            continue;
          }
          
          // W3
          if(charCodeType == BidiClassTypes.AL)  {
            _charsTypes[ix] = BidiClassTypes.R;
            continue;
          }
          
          
          // W4
          if(charCodeType == BidiClassTypes.ES)
          {
            prevCharTypeInRun = getPrevTypeInRun(ix,clr);
            nextCharTypeInRun = getNextTypeInRun(ix,clr);
            
            if((prevCharTypeInRun == BidiClassTypes.EN) && (nextCharTypeInRun == BidiClassTypes.EN) && (currentRunLastStrongType != BidiClassTypes.AL)) {
              _charsTypes[ix] = BidiClassTypes.EN;
            }
            continue;
          }
          
          if(charCodeType == BidiClassTypes.CS)
          {
            prevCharTypeInRun = getPrevTypeInRun(ix,clr);
            nextCharTypeInRun = getNextTypeInRun(ix,clr);
            
            if((prevCharTypeInRun == BidiClassTypes.EN) && (nextCharTypeInRun == BidiClassTypes.EN) && (currentRunLastStrongType != BidiClassTypes.AL)) {
              _charsTypes[ix] = BidiClassTypes.EN;
            }
            else if((prevCharTypeInRun == BidiClassTypes.AN) && (nextCharTypeInRun == BidiClassTypes.AN)) {
              _charsTypes[ix] = BidiClassTypes.AN;
            }
            else if((prevCharTypeInRun == BidiClassTypes.AN) && (nextCharTypeInRun == BidiClassTypes.EN) && (currentRunLastStrongType == BidiClassTypes.AL)) {
              // because in next iteration this next EN will become AN and that rule(W2) comes before W4
              _charsTypes[ix] = BidiClassTypes.AN;
            }
            continue;
          }
          
          
        }
        
      }
      
      
      //printOutput();
      
      // W5
      
      if(_applyRuleW5)
      {
        var nextTypeInRunExcludingET:String = null;
        var prevCharType:String;
        for(kx = 0; kx < levelRunsCount; kx++)
        {
          clr = _levelRuns[kx];
          currentRunLastStrongType = clr.sorType;
          prevCharType = clr.sorType;
          nextTypeInRunExcludingET = null;
          for(ix = clr.startIndex; ix < clr.EndIndex; ix++)
          {
            
            //charCode                = _textinput.charCodeAt(ix);
            charCodeType            = _charsTypes[ix];
            
            // X9 rule
            if(isIgnoredChar(charCodeType))
              continue;
            
            if(charCodeType == BidiClassTypes.ET)
            {
              if(nextTypeInRunExcludingET == null)
                nextTypeInRunExcludingET = getNextTypeInRunExcluding(ix, clr, BidiClassTypes.ET);
              
              prevCharType = getPrevTypeInRun(ix, clr);
              
              if(prevCharType == BidiClassTypes.EN)
                _charsTypes[ix] = BidiClassTypes.EN;
              else if(nextTypeInRunExcludingET == BidiClassTypes.EN)
                _charsTypes[ix] = BidiClassTypes.EN;
              else
                _charsTypes[ix] = BidiClassTypes.ON;
              
            }
            else {
              nextTypeInRunExcludingET = null;
            }
            
          }
        }
      }
      
      // W6 - W7
      for(kx = 0; kx < levelRunsCount; kx++)
      {
        clr = _levelRuns[kx];
        currentRunLastStrongType = clr.sorType;
        for(ix = clr.startIndex; ix < clr.EndIndex; ix++)
        {
          
          //charCode                = _textinput.charCodeAt(ix);
          charCodeType            = _charsTypes[ix];
          
          // X9 rule
          if(isIgnoredChar(charCodeType))
            continue;
          
          // keep track of last seen strong types in the run
          // this helps us to avoid re running on the entire run in the original
          // rule W3 as was defined in the original algorithm
          if(isStrongType(charCodeType))
            currentRunLastStrongType = charCodeType;
          
          // W6
          if((charCodeType == BidiClassTypes.ET) || (charCodeType == BidiClassTypes.CS) || (charCodeType == BidiClassTypes.ES))
          {
            _charsTypes[ix] = BidiClassTypes.ON;
            continue;
          }
          
          // W7
          if((charCodeType == BidiClassTypes.EN) && (currentRunLastStrongType == BidiClassTypes.L))
          {
            _charsTypes[ix] = BidiClassTypes.L;
            continue;
          }
          
        }
        
      }
      
      //printOutput();
      
      //trace();
    }
    
    /**
     * use this to iterate and avoid ignored types 
     */
    private function getNextIndexInRun(index:uint, levelRun:LevelRun):uint
    {
      var len:uint = _textinput.length;
      
      index = Math.min(index + 1, levelRun.EndIndex);
      
      for(var ix:uint = index; index < levelRun.EndIndex; ix++)
      {
        if(isIgnoredChar(_charsTypes[ix]) == false)
          return ix
      }
      
      return (levelRun.EndIndex - 1);
    }
    
    /**
     * use this to iterate and avoid ignored types 
     */
    private function getNextTypeInRunExcluding(index:uint, levelRun:LevelRun, excludedType:String):String
    {
      var len:uint = _textinput.length;
      
      index = Math.min(index + 1, levelRun.EndIndex);
      
      for(var ix:uint = index; index < levelRun.EndIndex; ix++)
      {
        if(isIgnoredChar(_charsTypes[ix]))
          continue;
        
        if(_charsTypes[ix] == excludedType)
          continue;
        
        return _charsTypes[ix];
      }
      
      if(levelRun.eorType == excludedType)
        return (null)
      return levelRun.eorType;
    }
    
    /**
     * use this to iterate and avoid ignored types 
     */
    private function getNextTypeInRun(index:uint, levelRun:LevelRun):String
    {
      var len:uint = _textinput.length;
      
      index = Math.min(index + 1, levelRun.EndIndex);
      
      for(var ix:uint = index; index < levelRun.EndIndex; ix++)
      {
        if(isIgnoredChar(_charsTypes[ix]) == false)
          return _charsTypes[ix];
      }
      
      return levelRun.eorType;
    }
    
    /**
     * use this to iterate and avoid ignored types 
     */
    private function getPrevTypeInRun(index:uint, levelRun:LevelRun):String
    {
      var len:uint = _textinput.length;
      
      index = Math.max(index - 1, levelRun.startIndex);
      
      for(var ix:uint = index; index >= levelRun.startIndex; ix--)
      {
        if(isIgnoredChar(_charsTypes[ix]) == false)
          return _charsTypes[ix];
      }
      
      return levelRun.sorType;
    }
    
    /**
     * use this to iterate and avoid ignored types 
     */
    private function getPrevIndexInRun(index:uint, levelRun:LevelRun):uint
    {
      var len:uint = _textinput.length;
      
      index = Math.max(index - 1, levelRun.startIndex);
      
      for(var ix:uint = index; index >= levelRun.startIndex; ix--)
      {
        if(isIgnoredChar(_charsTypes[ix]) == false)
          return ix
      }
      
      return levelRun.startIndex;
    }
    
    private function isStrongType(type:String):Boolean
    {
      if( (type == BidiClassTypes.AL) ||
        (type == BidiClassTypes.R) ||
        (type == BidiClassTypes.L) )
        return true;
      return false;
    }
    
    /**
     * level 1
     */
    private function explicitLevelsAndDirections():void
    {
      var textLength:uint = _textinput.length;
      var charCode:Number;
      var charCodeType:String;
      
      // X1
      setCurrentEmbeddingLevel(_paragraphEmbeddingLevel);
      _directionalOverrideStatus  = DirectionalOverrideStatus.Neutral;
      
      
      // X2 - X9
      // optimize for  non embedding
      for(var ix:uint = 0; ix < textLength; ix++)
      {
        charCode = _textinput.charCodeAt(ix);
        charCodeType = _bcdb.UCtoBidiClass(charCode);
        _charsTypes[ix] = charCodeType;
        // clean previously in place data
        _charsLevels[ix] = 0;
        
        _textOutput[ix] = _textinput.charAt(ix);
        
        switch(charCodeType)
        {
          case BidiClassTypes.BN:
          {
            break;
          }
          case BidiClassTypes.PDF:
          {
            _directionalOverrideStatus = _stackDirectionalOverrideStatus.pop();
            _currentEmbeddingLevel = _stackEmbeddingLevel.pop();
            
            break;
          }
          case BidiClassTypes.RLE:
          {
            if(setCurrentEmbeddingLevel(leastGreaterOdd(currentEmbeddingLevel)) == false)
              break;
            
            _stackDirectionalOverrideStatus.push(_directionalOverrideStatus);
            _directionalOverrideStatus = DirectionalOverrideStatus.Neutral;
            
            break;
          }
          case BidiClassTypes.LRE:
          {
            if(setCurrentEmbeddingLevel(leastGreaterEven(currentEmbeddingLevel)) == false)
              break;
            
            _stackDirectionalOverrideStatus.push(_directionalOverrideStatus);
            _directionalOverrideStatus = DirectionalOverrideStatus.Neutral;
            
            break;
          }
          case BidiClassTypes.RLO:
          {
            if(setCurrentEmbeddingLevel(leastGreaterOdd(currentEmbeddingLevel)) == false)
              break;
            
            _stackDirectionalOverrideStatus.push(_directionalOverrideStatus);
            _directionalOverrideStatus = DirectionalOverrideStatus.Right_To_Left;
            
            break;
          }
          case BidiClassTypes.LRO:
          {
            if(setCurrentEmbeddingLevel(leastGreaterEven(currentEmbeddingLevel)) == false)
              break;
            
            _stackDirectionalOverrideStatus.push(_directionalOverrideStatus);
            _directionalOverrideStatus = DirectionalOverrideStatus.Left_To_Right;
            
            break;
          }
            
          default:
          {
            _charsLevels[ix] = _currentEmbeddingLevel;
            
            if(_directionalOverrideStatus != DirectionalOverrideStatus.Neutral) {
              _charsTypes[ix] = _directionalOverrideStatus;
            }
            
            if(charCodeType == BidiClassTypes.ET)
              _applyRuleW5 = true;
            
            break;
          }
        }
        
      }
      
      //printOutput();
      //trace();
    }
    
    private function levelToType(level:int):String
    {
      if(level%2 == 0) 
        return BidiClassTypes.L;
      return BidiClassTypes.R;
    }
    
    
    private function leastGreaterOdd(value:uint):uint
    {
      if(value%2 == 0)
        return value + 1;
      return value + 2;
    }
    
    private function leastGreaterEven(value:uint):uint
    {
      if(value%2 == 1)
        return value + 1;
      return value + 2;
    }
    
    /**
     * 
     */
    public function get textinput():String  { return _textinput;  }
    public function set textinput(value:String):void  { _textinput = value; }
    
    public function get currentEmbeddingLevel():uint  { return _currentEmbeddingLevel;  }
    /**
     * 
     * @param value
     * @return True or False according to the validity
     * 
     */
    public function setCurrentEmbeddingLevel(value:uint):Boolean
    {
      if(_currentEmbeddingLevel > MAX_EMBEDDING_LEVEL) {
        return false;
      }
      
      _stackEmbeddingLevel.push(_currentEmbeddingLevel);
      _currentEmbeddingLevel = value;
      
      return true;
    }
    
    public function get directionalOverrideStatus():String  { return _directionalOverrideStatus;  }
    public function set directionalOverrideStatus(value:String):void
    {
      _stackDirectionalOverrideStatus.push(_directionalOverrideStatus);
      _directionalOverrideStatus = value;
    }
    
    public function get paragraphEmbeddingLevel():uint
    {
      return _paragraphEmbeddingLevel;
    }
    
    public function set paragraphEmbeddingLevel(value:uint):void
    {
      _paragraphEmbeddingLevel = value;
    }
    
  }
  
}