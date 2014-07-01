package plugin.astiny {
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class ASTCodegen 
	{
		
		private var out:ASTOutput = ASTOutput.getInstance();
		private var scanner:ASTScanner = ASTScanner.getInstance();
		private var param:ASTParam = ASTParam.getInstance();
		
		private static var _instance:ASTCodegen;
		
		public static function getInstance():ASTCodegen
		{
			if (!_instance)
			{
				_instance = new ASTCodegen();
			}
			return _instance;
		}
		
		public function ASTCodegen() 
		{
			
		}
		
		public function loadConstant(n:String):void
		{
			out.emitLn('MOVE #' + n + ',D0' );
		}
		
		public function loadVariable(name:String):void
		{
			out.emitLn('MOVE ' + name + '(PC),D0');
		}
		
		public function storeVariable(name:String):void
		{
			out.emitLn('LEA ' + name + '(PC),A0'); 
			out.emitLn('MOVE D0,(A0)'); 
		}
		
		public function negate():void
		{
			out.emitLn('NEG D0'); 
		}
		
		public function push():void
		{
			out.emitLn('MOVE D0,-(SP)');
		}
		
		public function pop():void
		{
			
		}
		
		public function popAdd():void
		{
			out.emitLn('ADD (SP)+,D0'); 
		}
		
		public function popSub():void
		{
			out.emitLn('SUB (SP)+,D0'); 
			negate();
		}
		
		public function popOr():void
		{
			out.emitLn('OR (SP)+,D0'); 
		}
		
		public function popXor():void
		{
			out.emitLn('EOR (SP)+,D0'); 
		}
		
		public function popMul():void
		{
			out.emitLn('MULS (SP)+,D0');
		}
		
		public function popDiv():void
		{
			out.emitLn('MOVE (SP)+,D7'); 
			out.emitLn('EXT.L D7'); 
			out.emitLn('DIVS D0,D7'); 
			out.emitLn('MOVE D7,D0');
		}
		
		public function popAnd():void
		{
			out.emitLn('AND (SP)+,D0'); 
		}
		
		public function notIt():void
		{
			out.emitLn('EOR #-1,D0');
		}
		
		
		public function callSubroutine():void
		{
			
		}
		
		public function header():void
		{
			
		}
		
		public function prolog():void
		{
			
		}
		
		public function epilog():void
		{
			
		}
		
		public function allocate(name:String, val:String):void
		{
			out.emitLn(name, ':', '\t', 'DC ', val);
		}
		
		public function readIt():void
		{
			out.emitLn('BSR READ');
			storeVariable( scanner.name );
		}
		
		public function writeIt():void
		{
			out.emitLn('BSR WRITE');
		}
		
		public function branchFalse(L:String):void
		{
			out.emitLn('TST D0');
			out.emitLn('BEQ ' + L);
		}
		
		public function branch(L:String):void
		{
			out.emitLn('BRA ' + L);
		}
		
		public function postLabel(L:String):void
		{
			out.emitLn(L, ':');
		}
		
		public function setEqual():void
		{
			out.emitLn('SEQ D0');
			out.emitLn('EXT D0');
		}
		
		public function popCompare():void
		{
			out.emitLn('CMP (SP)+,D0');
		}
		
		public function setLessOrEqual():void
		{
			out.emitLn('SGE D0');
			out.emitLn('EXT D0');
		}
		
		public function setGreaterOrEqual():void
		{
			out.emitLn('SLE D0');
			out.emitLn('EXT D0');
		}
		
		public function setNEqual():void
		{
			out.emitLn('SNE D0');
			out.emitLn('EXT D0');
		}
		
		public function setLess():void
		{
			out.emitLn('SGT D0');
			out.emitLn('EXT D0');
		}
		
		public function setGreater():void
		{
			out.emitLn('SGT D0');
			out.emitLn('EXT D0');
		}
		
		public function clear():void
		{
			out.emitLn('CLR D0');
		}
		
		
		public function returnFrom():void
		{
			
		}
		
		public function call(name:String):void
		{
			
		}
		
		
		public function loadParam(N:int):void
		{
			
			var offset:int = 4 + 4 * (param.base - N);
			
			out.emit('MOVE ');
			out.emitLn(offset, '(SP),D0');
		}
		
		public function storeParam(N:int):void
		{
			var offset:int = 4 + 4 * (param.base - N);
			
			out.emit('MOVE D0,');
			out.emitLn(offset, '(SP)');
		}
		
		public function cleanStack(N:int):void
		{
			if ( N > 0 )
			{
				out.emit('ADD #');
				out.emitLn(N, ',SP');
			}
		}
		
		public function procProlog(L:String, k:int):void
		{
			postLabel(L);
			out.emitLn('LINK A6,#0');
		}
		
		public function procEpilog():void
		{
			out.emitLn('UNLK A6');
			out.emitLn('RTS');
		}
		
	}

}