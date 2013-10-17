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

	var ok = true;
	var q = new PriorityQueue;
	ok &= q.empty();
	
	{
		var r = new Math.RandomNumberGenerator;
		for(var i=0;i<50;++i)
			q += r.equilikely(0,30);
		
		ok &= q.count() == 50;
		var n = 0;
		for(var i=0;i<10;++i){
			var n2 = q.extract();
			ok &= n2>=n;
			n = n2;
		}
		ok &= q.count() == 40;
		for(var i=0;i<10;++i)
			q += r.equilikely(0,30);
		ok &= q.count() == 50;
	
		n = 0;
		while(!q.empty()){
			var n2 = q.extract();
			ok &= n2>=n;
			n = n2;
		}
	}
	{
		var arr = [4,7,1,3];
		foreach(arr as var n2)
			q += n2;
		var q2 = q.clone();
		arr.sort();
		while(!q.empty()){
			var n2 = q.extract();
			ok &= n2 == q2.extract() && n2 == arr.popFront();
		}
	}
	q += 2;
	q.clear();
	ok &= q.empty();

	test("Std.PriorityQueue",
		Std.PriorityQueue == PriorityQueue  &&
		ok &&
		true );
}


// var s1 = new Set(4,5,1,3,4);

	// var s2 = new Set(1,3,4,7);
	// var s3 = s2.clone();
	// s2+=5;
	// s2-=7;
	
	// var s4 = new Set("foo","blub");
	// var s5 = new Set("foo","bar");
	
	// var s6 = s4|s5;
	// s4|=s5;
	
	
	// addResult("Basics",s1==s2 && s1!=s3 && s1.count()==4 && s4==new Set("foo","blub","bar") && s4==s6 && s5!=s6
			// && (s1 & new Set(3,4,9,"bla")) == new Set(3,4)
			// && s1.getSubstracted(new Set(3,4,9,"bla")) == new Set(1,5));
	
	
	// var sum=0;
	// foreach(s1 as var value)
		// sum+=value;
	
	// // \todo s1.max() does not work because s1 internally is an ExtObject, altough it should be a Collection object (which doesn't work).
	
	// addResult("Iterators", sum==1+3+4+5);
// loadOnce("LibUtilExt/DataWrapper.escript");

	// {
		// var sideLength = DataWrapper.createFromValue( 10 );
		// var area = DataWrapper.createFromFunctions( (fn(sideLength){	return sideLength()*sideLength(); }).bindLastParams(sideLength),
														// (fn(data,sideLength){	sideLength.set(data.sqrt());} ).bindLastParams(sideLength));
		
		// // propagate changes of the sideLength to the area. sideLength and data are now directly connected.
		// sideLength.onDataChanged += area->fn(data){refresh();};

		// var result = true;
		// // --------
		
		// result &= (area() == 100);
		// area(81);
		// result &= (sideLength() == 9);
		// sideLength(5);
		// result &= (area() == 25);
		// addResult("DataWrapper 1",result);
	// }
	
	// // --------
	
	// {
		// var a = new ExtObject({ $m : 3 });
		// var wrapper = DataWrapper.createFromAttribute(a,$m);
		
		// wrapper(wrapper()+20);
		// a.m+=100;
		// wrapper.refresh();
		
		// addResult("DataWrapper 2",wrapper() == 123 );
	// }
		
	// // --------
	
	// {
		// var map = { 'm' : 3 };
		// var wrapper = DataWrapper.createFromCollectionEntry(map,'m');
		// wrapper(wrapper()+20);
		// map['m'] += 100;

		// var array = [0,3,17];
		// var wrapper2 = DataWrapper.createFromCollectionEntry(array,1);

		// wrapper2(wrapper2()+20);
		// array[1] += 100;
		// addResult("DataWrapper 3",
					// wrapper() == 123 && map ==  { 'm' : 123 }
					// && wrapper2() == 123 && array==[0,123,17] );
	// }
	
	// // --------
	// {
		// var d1 = DataWrapper.createFromValue(1);
		// var g = new DataWrapperContainer({ 
				// $d2 : DataWrapper.createFromValue(2)
		// });
		// g.addDataWrapper($d1,d1);
		
		// var log = [];
		// g.onDataChanged += log->fn(key,value){
			// this+=""+key+":"+value;
		// };
		
		// g.merge({
			// $d3 : DataWrapper.createFromValue(3)
		// });

		
		// var sum = 0;
		// foreach(g.getValues() as var key,var value){
			// sum += value;
		// }
		// d1(10);
		// g.assign({ $d2 : 100 });
		// g.setValue($d3,1000);
		// var d3 = g.getDataWrapper($d3);
		// g.unset($d3);
		// d3(2000); // this should NOT occur in the log!
		
		// // test .getIterator()
		// var m = new Map;
		// foreach(g as var key,var value)
			// m[key] = value;
		
		// addResult("DataWrapperContainer",g[$d1] == 10 && g[$d2] == 100 
					// && d3() == 2000 && g.getValue($d4,"foo") == "foo" && sum == 6
					// && log == [ "d3:3","d1:10","d2:100","d3:1000" ]
					// && m == { "d1":10, "d2":100, "d3":2000 });
		// g.destroy(); // always destroy a DataWrapperContainer to remove all circling dependecies.
	// }

	// // --------

	
	// {	//Options
		// var options = [0,2,4];
		// var wrapper1 = DataWrapper.createFromValue(1).setOptions(options);
		// var wrapper2 = DataWrapper.createFromValue(2);
		// var wrapper3 = DataWrapper.createFromValue(3).setOptionsProvider( fn() { return [get(),get()*2,get()*3 ]; });
		
		// options+="Should not influence wrapper1's options.";
		
		// addResult("DataWrapperContainer",wrapper1.hasOptions() && !wrapper2.hasOptions()  && wrapper3.hasOptions() && 
					// wrapper1.getOptions()==[0,2,4] && wrapper2.getOptions()==[] && wrapper3.getOptions()==[3,6,9] );
	// }
	
