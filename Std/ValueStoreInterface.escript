// ValueStoreInterface.escript
// This file is part of the EScript StdLib library.
// See copyright notice in basics.escript
// ------------------------------------------------------

loadOnce(__DIR__+"/Traits/InterfaceTrait.escript");

Std.ValueStoreInterface := new Std.Traits.InterfaceTrait([
				$getValue,
				$setValue
	]);

// Std._registerModuleResult("Std/ValueStoreInterface",Std.ValueStoreInterface); // support loading with Std.requireModule and loadOnce.
return Std.ValueStoreInterface;

// ------------------------------------------
