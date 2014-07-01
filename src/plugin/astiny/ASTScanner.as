package plugin.astiny {
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class ASTScanner 
	{
		
		private static var _instance:ASTScanner;
		
		private static const ALPHA_REGEX:RegExp = /^[a-zA-Z]+$/
		private static const DIGIT_REGEX:RegExp  = /^[0-9]+$/
		private static const ALNUM_REGEX:RegExp = /^[a-zA-Z0-9]+$/
		
		
		private const input:ASTInput = ASTInput.getInstance();
		private const err:ASTError = ASTError.getInstance();
		
		
		private var _name:String;
		private var _number:String;
		
		/// BEGIN TINY STARTS HERE /////////////////////////////////
		private var _token:String;
		private var _value:String;
		/// END TINY STARTS HERE ///////////////////////////////////
		
		public static function getInstance():ASTScanner
		{
			if (!_instance)
			{
				_instance = new ASTScanner();
			}
			return _instance;
		}
		
		public function ASTScanner() 
		{
			_name = '';
			_number = '';
			_token = '';
			_value = '';
		}
		
		public function isAlpha(c:String):Boolean
		{
			return ALPHA_REGEX.test(c);
		}
		
		public function isDigit(c:String):Boolean
		{
			return DIGIT_REGEX.test(c);
		}
		
		public function isAlnum(c:String):Boolean
		{
			return ALNUM_REGEX.test(c);
		}
		
		public function isAddop(c:String):Boolean
		{
			return ((c == '+') || (c == '-') || (c == '|') || (c == '~'));
		}
		
		public function isMulop(c:String):Boolean
		{
			return ((c == '*') || (c == '/') || (c == '&'));
		}
		
		public function skipComment():void
		{
			while ( input.look != '}' )
			{
				input.getChar();
				if ( input.look == '{' )
				{
					skipComment();
				}
			}
			input.getChar();
		}
		
		public function isWhite(c:String):Boolean
		{
			return ((c == ' ') || (c == '\t') || (c == '\n') || (c == '\r')  || (c == '{'));
		}
		
		public function skipWhite():void
		{
			while (isWhite(input.look))
			{
				if ( input.look == '{' )
				{
					skipComment();
				}
				else
				{
					input.getChar();
				}
			}
		}
		
		//TODO add match(c:String):void for non TINY compilers
		
		public function getName():void
		{
			var i:int;
			
			skipWhite();
			if ( isAlpha(input.look) == false )
			{
				err.expected('Name');
			}
			
			i = 0;
			_value = '';
			_token = 'x';
			while ( isAlnum(input.look) )
			{
				_value += input.look;
				input.getChar();
			}
			
		}
		
		//TODO consider GetNumber int/String
		public function getNumber():String
		{
			var i:int;
			
			_name = '';
			if ( isDigit(input.look) == false )
			{
				err.expected('Integer');
			}
			while ( isDigit(input.look))
			{
				_number += input.look;
				input.getChar();
			}
			skipWhite();
			return _number;
		}
		
		
		
		/// TINY STARTS HERE ////////////////////////////////////////////////////////////////////
		public function getNum():void
		{
			var i:int;
			skipWhite();
			if ( isDigit(input.look) == false )
			{
				err.expected('Number');
			}
			
			_token = '#';
			_value = '';
			
			i = 0;
			while ( isDigit(input.look) )
			{
				_value += input.look;
				input.getChar();
			}
		}
		
		public function getOp():void
		{
			skipWhite();
			_token = input.look;
			_value = input.look;
			input.getChar();
		}
		
		public function next():void
		{
			skipWhite();
			if ( isAlpha(input.look) )
			{
				getName();
			}
			else if ( isDigit(input.look) )
			{
				getNum();
			}
			else
			{
				getOp();
			}
		}
		
		public function matchString(x:String):void
		{
			if ( _value != x )
			{
				err.expected( x + ' got ' + _value );
			}
			else
			{
				next();
			}
		}
		
		public function semi():void
		{
			var semiManditory:Boolean = false;
			
			if ( semiManditory )
			{
				matchString(';');
			}
			else if ( _token == ';' )
			{
				next();
			}
		}
		
		private var NKW:int = 12;
		private var NKW1:int = 13;
		
		private var KWList:Array = ['IF', 'ELSE', 'ENDIF', 'WHILE', 'ENDWHILE', 'READ', 'WRITE', 'VAR', 'END', 'PROGRAM', 'PROCEDURE', 'FUNCTION'];
		private var KWCode:Array = ['x', 'i', 'l', 'e', 'w', 'e', 'R', 'W', 'v', 'e', 'P', 'p', 'F'];
		
		public function scan():void
		{
			var i:int;
			
			if ( _token == 'x' )
			{
				for ( i = 0; i < NKW; i++ )
				{
					if ( _value == KWList[i] )
					{
						_token = KWCode[i + 1];
					}
				}
			}
		}
		
		public function isRelop(c:String):Boolean
		{
			return ((c == '=') || (c == '#') || (c == '<') || (c == '>'));
		}
		
		public function isOrOp(c:String):Boolean
		{
			return ((c == '|') || (c == '~'));
		}
		
		public function get name():String 
		{
			return _name;
		}
		
		public function get token():String 
		{
			return _token;
		}
		
		public function get value():String 
		{
			return _value;
		}
		
	}

}