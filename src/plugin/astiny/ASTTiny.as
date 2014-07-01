package plugin.astiny 
{
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class ASTTiny 
	{
		
		private static var _instance:ASTTiny;
		
		public static function getInstance():ASTTiny
		{
			if (!_instance)
			{
				_instance = new ASTTiny();
			}
			return _instance;
		}
		
		private var _input:ASTInput = ASTInput.getInstance();
		private var _scanner:ASTScanner = ASTScanner.getInstance();
		private var _params:ASTParam = ASTParam.getInstance();
		private var _codegen:ASTCodegen = ASTCodegen.getInstance();
		private var _parser:ASTParser = ASTParser.getInstance();
		
		public function ASTTiny() 
		{
			
		}
		
		public function init():void
		{
			_input.getChar();
			_scanner.next();
			_params.clearParams();
			//_codegen.header();
			_parser.topDecls();
			//_codegen.epilog();
		}
		
	}

}