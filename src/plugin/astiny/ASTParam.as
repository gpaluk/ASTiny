package plugin.astiny {
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class ASTParam 
	{
		private const err:ASTError = ASTError.getInstance();
		
		private static const PARAM_SIZE:int = 100;
		private static var _instance:ASTParam;
		private static var _paramType:Array;
		private static var _param:Array;
		
		public var numParams:int;
		public var base:int;
		
		public static function getInstance():ASTParam
		{
			if (!_instance)
			{
				_instance = new ASTParam();
			}
			return _instance;
		}
		
		public function ASTParam()
		{
			_paramType = [];
			_param = [];
			for ( var i:int = 0; i < PARAM_SIZE; ++i )
			{
				_param[i] = [];
			}
			
			clearParams();
		}
		
		public function clearParams():void
		{
			var i:int;
			var j:int;
			for ( i = 0; i < PARAM_SIZE; i++ )
			{
				_param[i] = ''
				_paramType[i] = ' ';
			}
			numParams = 0;
		}
		
		public function paramNumber(n:String):int
		{
			var i:int;
			for ( i = 0; i < PARAM_SIZE; i++ )
			{
				if ( n == _param[i] )
				{
					return i;
				}
			}
			err.expected( 'ParamNumber: Not found' );
			return -1;
		}
		
		public function isParam(symbol:String):Boolean
		{
			var i:int;
			for ( i = 0; i < numParams; ++i )
			{
				if ( symbol == _param[i] )
				{
					return true;
				}
			}
			return false;
		}
		
		public function addParam(name:String):void
		{
			if ( isParam(name) )
			{
				err.error( 'Duplicate parameter name ' + name );
			}
			_param[numParams] = name;
			numParams++;
		}
		
	}

}