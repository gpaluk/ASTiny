package plugin.astiny {
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class ASTSymbol 
	{
		
		private static var _instance:ASTSymbol;
		
		private static const STSize:int = 100;
		private static var NEntry:int = 0;
		private static var SType:Array = [];
		private static var ST:Array = [];
		
		private var _err:ASTError = ASTError.getInstance();
		private var _param:ASTParam = ASTParam.getInstance();
		
		public static function getInstance():ASTSymbol
		{
			if (!_instance)
			{
				_instance = new ASTSymbol();
			}
			return _instance;
		}
		
		public function ASTSymbol() 
		{
			
		}
		
		public function checkDup(symbol:String):void
		{
			if ( inTable(symbol))
			{
				_err.error( 'Duplicate symbol:' + symbol + '.' );
			}
		}
		
		public function inTable(symbol:String):Boolean
		{
			var i:int = 0;
			for ( i = 0; i < NEntry; i++)
			{
				if ( symbol == ST[i])
				{
					return true;
				}
			}
			return false;
		}
		
		public function addEntry(symbol:String, type:String):void
		{
			checkDup(symbol);
			if (NEntry == STSize)
			{
				_err.error('Symbol Table Full');
			}
			ST[NEntry] = symbol;
			SType[NEntry] = type;
			NEntry++;
		}
		
		public function typeOf(symbol:String):String
		{
			var i:int = 0;
			
			if ( _param.isParam(symbol))
			{
				return 'f';
			}
			
			for ( i = 0; i < NEntry; ++i )
			{
				if ( symbol == ST[i] )
				{
					return SType[i];
				}
			}
			return ' ';
		}
		
	}

}