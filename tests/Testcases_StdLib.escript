loadOnce("Std/basics.escript");
Std.addModuleSearchPath(".");

{
	var MultiProcedure = Std.require('Std/MultiProcedure');

	var p1 = new MultiProcedure;
	p1 += fn(p...){
		outln(p...);
	};
	p1(1,2,3);

	test("Std.MultiProcedure",
		Std.MultiProcedure == MultiProcedure  &&
		true );
}
{
	var Set = Std.require('Std/Set');

	var s1 = new Set;

	test("Std.Set",
		Std.Set == Set  &&
		true );
}
{
	var PriorityQueue = Std.require('Std/PriorityQueue');

	var s1 = new PriorityQueue;

	test("Std.PriorityQueue",
		Std.PriorityQueue == PriorityQueue  &&
		true );
}
