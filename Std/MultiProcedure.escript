// MultiProcedure.escript
// This file is part of the EScript StdLib library.
// See copyright notice in basics.escript
// ------------------------------------------------------

loadOnce(__DIR__+"/basics.escript");

/*! Expendable function without result.
	\example
		var f = new Std.MultiProcedure;
		f+=fn(a){out( "x:",a,"\n" );};
		f+=fn(a){out( "y:",(a+1),"\n" );};
		f+=fn(a){out( "z:",(a+2),"\n"); return Std.MultiProcedure.REMOVE; }; // removed after one call

		f(27);
		// x:27
		// y:28
		// z:29
		f(27);
		// x:27
		// y:28
	*/

var T = new Type;

T._printableName @(override) ::= $MultiProcedure;
T.REMOVE ::= $REMOVE;
T.functions @(private,init) := Array;
T._call ::= fn(obj,params...){
	for(var i = 0;i<functions.count();){
		if( REMOVE == (obj->functions[i])(params...) ){
			functions.removeIndex(i);
		}else{
			++i;
		}
	}
};
T."+=" ::= fn(f){	this.functions += f;	};
T.accessFunctions ::= fn(){	return functions;	};
T.clear ::= fn(){	return functions.clear();	};
T.clone ::= fn(){
	var other = new this.getType();
	(other->fn(f){	functions = f;	})(functions.clone());
	return other;
};
T.count ::= fn(){	return functions.count();	};
T.empty ::= fn(){	return functions.empty();	};
T.filter ::= fn(fun){
	functions.filter(fun);
	return this;
};

//!	\see Std.Traits.CallableTrait
Std.require('Std/Traits/basics').addTrait( T, Std.require('Std/Traits/CallableTrait') );


Std.MultiProcedure := T;

//// support loading with Std.requireModule and loadOnce.
//Std._unregisterModule("Std/MultiProcedure");
//Std._registerModule("Std/MultiProcedure",Std.MultiProcedure);

return Std.MultiProcedure;
// ------------------------------------------
