package plugin.astiny {
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class ASTOutput 
	{
		
		private static var _instance:ASTOutput;
		
		private var _lineBuffer:String;
		
		public static function getInstance():ASTOutput
		{
			if (!_instance)
			{
				_instance = new ASTOutput();
			}
			return _instance;
		}
		
		public function ASTOutput() 
		{
			_lineBuffer = '';
		}
		
		public function emit(...rest):void
		{
			for each( var o:* in rest )
			{
				_lineBuffer += o;
			}
		}
		
		public function emitLn(...rest):void
		{
			for each( var o:* in rest )
			{
				_lineBuffer += o;
			}
			trace( _lineBuffer );
			_lineBuffer = '';
		}
		
	}

}