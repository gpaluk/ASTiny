package plugin.astiny {
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class ASTError 
	{
		
		private static var _instance:ASTError;
		
		public static function getInstance():ASTError
		{
			if (!_instance)
			{
				_instance = new ASTError();
			}
			return _instance;
		}
		
		public function error(s:String):void
		{
			throw new Error('Error: ' + s + '.');
		}
		
		public function expected(s:String):void
		{
			error(s + ' expected');
		}
		
	}

}