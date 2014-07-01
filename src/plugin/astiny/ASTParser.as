package plugin.astiny {
	/**
	 * ...
	 * @author Gary Paluk - http://www.plugin.io
	 */
	public class ASTParser 
	{
		
		private var _in:ASTInput = ASTInput.getInstance();
		private var _out:ASTOutput = ASTOutput.getInstance();
		private var _scanner:ASTScanner = ASTScanner.getInstance();
		private var _err:ASTError = ASTError.getInstance();
		private var _codegen:ASTCodegen = ASTCodegen.getInstance();
		private var _symbol:ASTSymbol = ASTSymbol.getInstance();
		private var _param:ASTParam = ASTParam.getInstance();
		
		private static var _instance:ASTParser;
		private static var count:int = 0;
		
		public static function getInstance():ASTParser
		{
			if (!_instance)
			{
				_instance = new ASTParser();
			}
			return _instance;
		}
		
		public function ASTParser() 
		{
			
		}
		
		public function alloc():void
		{
			_scanner.next();
			if (_scanner.token != 'x')
			{
				_err.expected('Variable Name');
			}
			_symbol.checkDup(_scanner.value );
			_symbol.addEntry(_scanner.value, 'v' );
			_codegen.allocate(_scanner.value, '0' );
			_scanner.next();
		}
		
		public function beginBlock():void
		{
			_scanner.matchString('BEGIN');
			block();
			_scanner.matchString('END');
			_scanner.semi();
		}
		
		public function doMain():void
		{
			var name:String;
			
			_scanner.matchString("PROGRAM");
			name = _scanner.value;
			_symbol.checkDup(name);
			_scanner.semi();
			_codegen.prolog();
			_scanner.next();
			beginBlock();
		}
		
		public function formalParam():void
		{
			var name:String;
			name = _scanner.value;
			_param.addParam(name);
			_scanner.next();
		}
		
		public function formalList():void
		{
			_scanner.matchString('(');
			if (_scanner.token != ')')
			{
				formalParam();
				while (_scanner.token == ',')
				{
					_scanner.next();
					formalParam();
				}
			}
			_scanner.matchString(')');
			_param.base = _param.numParams;
			_param.numParams += 2;
		}
		
		public function localAlloc():void
		{
			_scanner.next();
			if (_scanner.token != 'x' )
			{
				_err.expected( 'Variable Name' );
			}
			_param.addParam(_scanner.value);
			_scanner.next();
		}
		
		public function locDecl():int
		{
			var n:int;
			while (_scanner.scan(), _scanner.token == 'v' )
			{
				localAlloc();
				n++;
				while ( _scanner.token == ',' )
				{
					localAlloc();
					n++;
				}
				_scanner.semi();
			}
			return n;
		}
		
		public function locDecls():int
		{
			var n:int;
			
			while ( _scanner.scan(), _scanner.token == 'v')
			{
				n += locDecl();
			}
			return n;
		}
		
		public function doProc():void
		{
			var name:String;
			var k:int;
			
			_scanner.matchString('PROCEDURE');
			name = _scanner.value;
			_symbol.checkDup(_scanner.value);
			_symbol.addEntry(_scanner.value, 'p');
			_scanner.next();
			formalList();
			k = locDecls();
			_codegen.procProlog(name,k);
			beginBlock();
			_codegen.procEpilog();
			_param.clearParams();
		}
		
		public function doFunc():void
		{
			var name:String;
			var k:int;
			
			_scanner.matchString('FUNCTION');
			name = _scanner.value;
			_symbol.checkDup(_scanner.value);
			_symbol.addEntry(_scanner.value, 'p');
			_scanner.next();
			formalList();
			k = locDecls();
			_codegen.procProlog(name,k);
			beginBlock();
			_codegen.procEpilog();
			_param.clearParams();
		}
		
		/*
		public function or():void
		{
			
		}
		
		public function xor():void
		{
			
		}
		
		public function and():void
		{
			
		}
		*/
		
		public function decl():void
		{
			while ( _scanner.scan(), _scanner.token == 'v' )
			{
				alloc();
				while ( _scanner.token == ',')
				{
					alloc();
				}
				_scanner.semi();
			}
		}
		
		public function topDecls():void
		{
			_scanner.scan();
			while ( _scanner.token != '.' )
			{
				switch( _scanner.token )
				{
					case 'v':
							decl();
						break;
					case 'p':
							doProc();
						break;
					case 'f':
							doFunc();
						break;
					case 'P':
							doMain();
						break;
					default:
						_err.error( 'TopDecls: Unregognized keyword ' + _scanner.token );
				}
			}
			/*
			while ( _scanner.scan(), _scanner.token == 'v' )
			{
				alloc();
				while ( _scanner.token == ',' )
				{
					alloc();
				}
				_scanner.semi();
			}
			*/
		}
		
		public function newLabel():String
		{
			count++;
			return count.toString();
		}
		
		public function doIf():void
		{
			var L1:String;
			var L2:String;
			
			_scanner.next();
			boolExpression();
			L1 = newLabel();
			L2 = L1;
			_codegen.branchFalse( L1 );
			block();
			if ( _scanner.token == 'l' )
			{
				_scanner.next();
				L2 = newLabel();
				_codegen.branch( L2 );
				_codegen.postLabel( L1 );
				block();
			}
			_codegen.postLabel( L2 );
			_scanner.matchString( 'ENDIF' );
		}
		
		public function doWhile():void
		{
			var L1:String;
			var L2:String;
			
			_scanner.next();
			L1 = newLabel();
			L2 = newLabel();
			_codegen.postLabel(L1);
			boolExpression();
			_codegen.branchFalse(L2);
			block();
			_scanner.matchString( 'ENDWHILE' );
			_codegen.branch(L1);
			_codegen.postLabel(L2);
		}
		
		public function checkIndent():void
		{
			if ( _scanner.token != 'x' )
			{
				_err.expected( 'CheckIdent: expected identifier' );
			}
		}
		
		public function checkTable(symbol:String ):void
		{
			if ( _symbol.inTable( symbol ) == false )
			{
				_err.error( 'CheckTable: Undefined ' + symbol+ '.' );
			}
		}
		
		public function readVar():void
		{
			_codegen.readIt();
			if ( _param.isParam(_scanner.value ) )
			{
				_codegen.storeParam( _param.paramNumber( _scanner.value ) );
			}
			else
			{
				checkTable(_scanner.value )
				_codegen.storeVariable(_scanner.value );
			}
			_scanner.next();
		}
		
		public function doRead():void
		{
			_scanner.next();
			_scanner.matchString('(');
			readVar();
			while ( _scanner.token == ',' )
			{
				_scanner.next();
				readVar();
			}
			_scanner.matchString( ')' );
		}
		
		public function factor():void
		{
			if ( _scanner.token == '(' )
			{
				_scanner.next();
				boolExpression();
				_scanner.matchString(')');
			}
			else
			{
				if ( _scanner.token == 'x' )
				{
					if ( _param.isParam( _scanner.value ) )
					{
						_codegen.loadParam( _param.paramNumber( _scanner.value ) );
					}
					else
					{
						checkTable( _scanner.value );
						_codegen.loadVariable( _scanner.value );
					}
				}
				else if ( _scanner.token == '#' )
				{
					_codegen.loadConstant(_scanner.value );
				}
				else
				{
					_err.expected('Math Factor');
				}
				_scanner.next();
			}
		}
		
		public function multiply():void
		{
			_scanner.next();
			factor();
			_codegen.popMul();
		}
		
		public function divide():void
		{
			_scanner.next();
			factor();
			_codegen.popDiv();
		}
		
		public function term():void
		{
			factor();
			while ( _scanner.isMulop( _scanner.token ) )
			{
				_codegen.push();
				switch( _scanner.token )
				{
					case '*':
							multiply();
						break;
					case '/':
							divide();
						break;
				}
			}
		}
		
		public function add():void
		{
			_scanner.next();
			term();
			_codegen.popAdd();
		}
		
		public function subtract():void
		{
			_scanner.next();
			term();
			_codegen.popSub();
		}
		
		public function expression():void
		{
			if ( _scanner.isAddop( _scanner.token ) )
			{
				_codegen.clear();
			}
			else
			{
				term();
			}
			while ( _scanner.isAddop( _scanner.token ) )
			{
				_codegen.push();
				switch(_scanner.token )
				{
					case '+':
							add();
						break;
					case '-':
							subtract();
						break;
				}
			}
		}
		
		public function doWrite():void
		{
			_scanner.next();
			_scanner.matchString('(');
			expression();
			_codegen.writeIt();
			while ( _scanner.token == ',')
			{
				_scanner.next();
				expression();
				_codegen.writeIt();
			}
			_scanner.matchString(')');
		}
		
		public function compareExpression():void
		{
			expression();
			_codegen.popCompare();
		}
		
		public function nextExpression():void
		{
			_scanner.next();
			compareExpression();
		}
		
		public function equal():void
		{
			nextExpression();
			_codegen.setEqual();
		}
		
		public function lessOrEqual():void
		{
			nextExpression();
			_codegen.setLessOrEqual();
		}
		
		public function notEqual():void
		{
			nextExpression();
			_codegen.setNEqual();
		}
		
		public function less():void
		{
			_scanner.next();
			switch( _scanner.token )
			{
				case '=':
						lessOrEqual();
					break
				case '>':
						notEqual();
					break
				default:
					compareExpression();
					_codegen.setLess();
			}
		}
		
		public function greater():void
		{
			_scanner.next();
			if ( _scanner.token == '=' )
			{
				nextExpression();
				_codegen.setGreaterOrEqual();
			}
			else
			{
				compareExpression();
				_codegen.setGreater();
			}
		}
		
		public function relation():void
		{
			expression();
			if ( _scanner.isRelop( _scanner.token ) )
			{
				_codegen.push();
				switch( _scanner.token )
				{
					case '=':
							equal();
						break;
					case '<':
							less();
						break;
					case '>':
							greater();
						break;
				}
			}
		}
		
		public function notFactor():void
		{
			if ( _scanner.token == '!' )
			{
				_scanner.next();
				relation();
				_codegen.notIt();
			}
			else
			{
				relation();
			}
		}
		
		public function boolTerm():void
		{
			notFactor();
			while ( _scanner.token == '&' )
			{
				_codegen.push();
				_scanner.next();
				notFactor();
				_codegen.popAnd();
			}
		}
		
		public function boolOr():void
		{
			_scanner.next();
			boolTerm();
			_codegen.popOr();
		}
		
		public function boolXor():void
		{
			_scanner.next();
			boolTerm();
			_codegen.popXor();
		}
		
		public function boolExpression():void
		{
			boolTerm();
			while ( _scanner.isOrOp(_scanner.token))
			{
				_codegen.push();
				switch( _scanner.token )
				{
					case '|':
							boolOr();
						break;
					case '~':
							boolXor();
						break;
				}
			}
		}
		
		public function assignment():void
		{
			var name:String = _scanner.value;
			_scanner.next();
			_scanner.matchString('=');
			boolExpression();
			if (_param.isParam(name))
			{
				_codegen.storeParam( _param.paramNumber( name ));
			}
			else
			{
				_codegen.storeVariable( name );
			}
		}
		
		public function param():void
		{
			expression();
			_codegen.push();
		}
		
		public function paramList():int
		{
			var bytesPushed:int;
			
			_scanner.matchString('(');
			if ( _scanner.token != ')' )
			{
				paramList();
				bytesPushed += 4;
				while ( _scanner.token == ',' )
				{
					_scanner.next();
					param();
					bytesPushed += 4;
				}
			}
			_scanner.matchString(')');
			return bytesPushed;
		}
		
		public function callProc(name:String):void
		{
			var bytesPushed:int;
			
			_scanner.next();
			bytesPushed = paramList();
			_codegen.call(name);
			_codegen.cleanStack(bytesPushed);
		}
		
		public function assignOrProc():void
		{
			var name:String = _scanner.name;
			switch( _symbol.typeOf(name))
			{
				case ' ':
						_err.error( 'Identifier ' + name + 'is undefined.' );
					break;
				case 'v':
				case 'f':
						assignment();
					break;
				case 'p':
						callProc(name);
					break;
				default:
					_err.error( 'Identifier ' + name + 'cannot be used here.' );
			}
		}
		
		public function block():void
		{
			var token:String = _scanner.token;
			
			while ( _scanner.scan(), token != 'e' && token != 'l' )
			{
				switch( token )
				{
					case 'i':
							doIf();
						break;
					case 'w':
							doWhile();
						break;
					case 'R':
							doRead();
						break;
					case 'W':
							doWrite();
						break;
					case 'x':
							assignOrProc();
						break;
				}
			}
		}
		
	}

}