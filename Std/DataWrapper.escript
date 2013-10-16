// DataWrapper.escript
// This file is part of the EScript StdLib library.
// See copyright notice in basics.escript
// ------------------------------------------------------

loadOnce(__DIR__+"/basics.escript");

// Problem: JSONDataWrapper refresh on get
// map getOrSet(key, default)????

var DataWrapper = new Type;
{
	/*! A DataWrapper encapsulates a value that can be internally stored as attribute,
		inside of a JSONValueStore, or which is accessible only by function calls.
		A DataWrapper provides an unified interface, independently from the real location of the value.
	*/
	var T = DataWrapper;
	Std.DataWrapper := T;
	T._printableName @(override) ::= $DataWrapper;

	T.currentValue @(private) := void;
	T.refreshOnGet @(private) := false;

	//! (internal) ---o
	T.doGet @(private) ::= 		Std.ABSTRACT_METHOD;

	//! (internal) ---o
	T.doSet @(private) ::= 		Std.ABSTRACT_METHOD;

	//! (internal)
	T.initCurrentValue @(private) ::= fn(value,_refreshOnGet){
		currentValue = value;
		refreshOnGet = _refreshOnGet;
	};

	/*! ---o
		\note Do NOT alter the returned value if it is not a primitive value! If you have to, clone it and the set it again!	*/
	T.get ::= fn(){
		if(refreshOnGet)
			refresh();
		return currentValue;
	};

	//! Like refresh(), but always calls onDataChanged(newData) even if the value didn't change.
	t.forceRefresh ::= fn(){
		currentValue = doGet();
		onDataChanged(currentValue);
	};

	/*! Called when the value has been changed.
		To add a custom listener use the '+=' operator. E.g.
		\code
			myDataWrapper += fn(newData){	out("The value is now:",newData); };
	*/
	T.onDataChanged @(init) := MultiProcedure;

	/*! Refresh the internal data from the dataWrapper's data source. If the data has changed,
		onDataChanged(newData) is called. This function has only to be called  manually if the connected data may change externally.*/
	T.refresh ::= fn(){
		var newValue = doGet();
		if( !(currentValue==newValue) ){
			currentValue = newValue;
			onDataChanged(newValue);
		}
	};

	/*! ---o
		Set a new value. If the value does not equal the old value, onDataChanged(...) is called. */
	T.set ::= fn(newValue){
		if(! (currentValue==newValue) ){
			doSet(newValue);
			currentValue = doGet();
			onDataChanged(newValue);
		}
		return this;
	};

	/*! Use a DataWrapper as a function without parameters to get its value; use it with one parameter to set its value.
		\code
			var myDataWrapper = Std.DataWrapper.createFromValue(5);
			myDataWrapper(10);  // is the same as myDataWrapper.set(10);
			out( myDataWrapper() ); // outputs '10'. Is the same as out( myDataWrapper.get() );
	*/
	Std.require('Std/Traits/basics').addTrait(T,Std.require('Std/Traits/CallableTraits'),fn(obj,params...){
		return params.empty() ? this.get() : this.set(params...);
	});

	// ---------------
	// Options represent typical values for the dataWrapper. They are mainly used to automatically fill the corresponding field in a corresponding gui component.

	//! Returns an array of possible default values
	T.getOptions ::= fn(){
		return this.isSet($_options) ?
			(this._options---|>Array ? this._options.clone() : (this->this._options) () ) : [];
	};

	//! Returns if the dataWrapper has possible default values
	T.hasOptions ::= fn(){
		return this.isSet($_options);
	};

	//! Set an Array of possible default values. Returns this.
	T.setOptions ::= fn(Array options){
		this._options @(private) := options.clone();
		return this;
	};

	/*! Set a function providing options (caller is the DataWrapper, must return an Array).
		\code
			var myDataWrapper = Std.DataWrapper.createFromValue(5).setOptionsProvider( fn(){ return [this(),this()*2] } );
			print_r(myDataWrapper.getOptions()); // [5,10]
	*/
	T.setOptionsProvider ::= fn(callable){
		this._options @(private) := callable;
		return this;
	};
}
// ------------------------------------------
// (internal) AttributeWrapper ---|> DataWrapper
{
	var T = new Type(DataWrapper);
	T._printableName @(override) ::= $AttributeWrapper;

	//! ctor
	T._constructor ::= fn(_obj,Identifier _attr){
		this.obj @(private) := _obj;
		this.attr @(private) := _attr;
		this.initCurrentValue(doGet(),true);
	};

	//! ---|> DataWrapper
	T.doGet @(override,private) ::= 	fn(){	return obj.getAttribute(attr);	};

	//! ---|> DataWrapper
	T.doSet @(override,private) ::= 	fn(newValue){	obj.assignAttribute(attr, newValue);	};



	/*! (static) Factory
		Creates a DataWrapper connected to an object's attribute.
		\code var someValue = DataWrapper.createFromAttribute( someObject, $attr );
		\note refreshOnGet is set to true. */
	DataWrapper.createFromAttribute ::= T->fn( obj, Identifier attrName){
		return new this(obj,attrName);
	};

}

// ------------------------------------------
// (internal) EntryWrapper ---|> DataWrapper
{
	var T = new Type(DataWrapper);
	
	T._printableName @(override) ::= $EntryWrapper;
	//! ctor
	T._constructor ::= fn(_collection,_key){
		this.collection @(private) := _collection;
		this.key @(private) := _key;
		this.initCurrentValue(doGet(),true);
	};

	//! ---|> DataWrapper
	T.doGet @(override,private) ::= 	fn(){	return collection[key];	};

	//! ---|> DataWrapper
	T.doSet @(override,private) ::= 	fn(newValue){	collection[key] = newValue;	};
	
	/*! (static) Factory
		Creates a DataWrapper connected to a collection's entry.
		\code	var values = { 'foo' : 1, 'bar' : 2 };
				var someValue = DataWrapper.createFromEntry( values, key, 'foo' );
		\note refreshOnGet is set to true. */
	DataWrapper.createFromEntry ::= T->fn(collection, key, defaultValue=void){
		//! \todo query collectionInterface !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		
		return new this(collection,key,defaultValue);
	};

}

// ------------------------------------------
// (internal) SimpleValueWrapper ---|> DataWrapper
{
	var T = new Type(DataWrapper);
	T._printableName @(override) ::= $SimpleValueWrapper;
	//! ctor
	T._constructor ::= fn(_value){
		initCurrentValue(_value,false);
	};
	//! ---|> DataWrapper
	T.doGet @(override,private) ::= fn(){	return currentValue;	};

	//! ---|> DataWrapper
	T.doSet @(override,private) ::= fn(newValue){ currentValue = newValue; };
	
	//! (static) Factory
	T.createFromValue ::= T->fn(value){
		return new this(value);
	};
}

// ------------------------------------------
// (internal) FnDataWrapper ---|> DataWrapper
{
	var T = new Type(DataWrapper);
	T._printableName @(override) ::= $FnDataWrapper;
	//! ctor
	T._constructor ::= fn(_getter,_setter,Bool _refreshOnGet){
		this.doGet @(override,private) := _getter;
		this.doSet @(override,private) := _setter ? _setter : fn(data){ }; // ignore
		initCurrentValue(doGet(),_refreshOnGet);
	};

	/*! (static) Factory
		Create a dataWrapper from a pair of functions.
		\code var someValue = Std.DataWrapper.createFromFunctions( A->fn(){ return this.m1;},  A->fn(newValue){ this.m1 = newValue; } );
		\param getter Parameterless function called to get the current value
		\param setter (optional; may be void) Function with one parameter called to set the current value
		\param _refreshOnGet Iff true, the data is refreshed implicitly (=the getter is called) when calling get().
				Iff false, the last queried value is returned by get().
	*/
	DataWrapper.createFromFunctions ::= T->fn(getter, setter = void,_refreshOnGet = false){
		return new this(getter,setter,_refreshOnGet);
	};
}





// Std._registerModuleResult("Std/DataWrapper",Std.DataWrapper); // support loading with Std.requireModule and loadOnce.
//Std._markAsLoaded(__DIR__,__FILE__);

return DataWrapper;

// ----------------------------------------------------------------------------------------------------
// DataWrapperContainer   !!!!!!!EXPERIMENTAL!!!!!!!!!!!

GLOBALS.DataWrapperContainer := new Type;
DataWrapperContainer._printableName @(override) ::= $DataWrapperContainer;

DataWrapperContainer.dataWrappers @(init,private) := Map;

//! ---o
DataWrapperContainer.onDataChanged @(init) := MultiProcedure;

/*! (ctor) */
DataWrapperContainer._constructor ::= fn([void,Map] source=void){
    if(source)
        this.merge(source);
};

DataWrapperContainer.assign ::= fn(Map _values,warnOnUnknownKey = true){
	foreach(_values as var key,var value)
		this.setValue(key,value,warnOnUnknownKey);
	return this;
};

DataWrapperContainer.clear ::= fn(){
	foreach(this.dataWrappers as var dataWrapper)
		dataWrapper.onDataChanged.filter(this->fn(fun){		return !(fun---|>UserFunction && fun.getBoundParams()[0]==this);	});
	this.dataWrappers.clear();
	return this;
};

DataWrapperContainer.count ::=			fn(){	dataWrappers.count();	};

//! Call to remove all cycling dependencies with the contained DataWrappers
DataWrapperContainer.destroy ::= fn(){
	this.clear();
	this.dataWrappers = void; // prevent further usage.
	return this;
};
DataWrapperContainer.empty ::=			fn(){	this.dataWrappers.empty();	};
DataWrapperContainer.getValue ::= fn(key,defaultValue = void){
	var dataWrapper = this.dataWrappers[key];
	return dataWrapper ? dataWrapper() : defaultValue;
};
DataWrapperContainer.getDataWrapper ::= fn(key){	return this.dataWrappers[key];	};
DataWrapperContainer.getDataWrappers ::= fn(){	return this.dataWrappers.clone();	};

DataWrapperContainer.getValues ::= fn(){
	var m = new Map;
	foreach(this.dataWrappers as var key,var dataWrapper)
		m[key] = dataWrapper();
	return m;
};
DataWrapperContainer.containsKey ::= fn(key){
	return this.dataWrappers.containsKey(key);
};
DataWrapperContainer.merge ::= fn(Map _dataWrappers){
	foreach(_dataWrappers as var key,var dataWrapper)
		this.addDataWrapper(key,dataWrapper);
	return this;
};

/*! Add a new Datawrapper with the given key.
	\note calles onDataChanged(key, valueOfTheDataWrapper)	*/
DataWrapperContainer.addDataWrapper ::= fn(key, DataWrapper dataWrapper){
	if(this.dataWrappers[key])
		this.unset(key);
	this.dataWrappers[key] = dataWrapper;
	// it is important that the first parameter bound is this object as it is used to identify the function on removal.
	dataWrapper.onDataChanged += (fn(container,key,value){
		container.onDataChanged(key,value);
	}).bindFirstParams(this,key);
	this.onDataChanged(key,dataWrapper());
	return this;
};

DataWrapperContainer.setValue ::= fn(key,value,warnOnUnknownKey = true){
	var dataWrapper = this.dataWrappers[key];
	if(dataWrapper){
		dataWrapper(value);
	}else{
		if(warnOnUnknownKey)
			Runtime.warn("DataWrapperContainer.setValue(...) unknown entry '"+key+"'.");
	}
	return this;
};

DataWrapperContainer.unset ::= fn(key){
	var dataWrapper =this. dataWrappers[key];
	if(dataWrapper){
		dataWrapper.onDataChanged.filter(this->fn(fun){
			return !(fun---|>UserFunction && fun.getBoundParams()[0]==this);
		});
	}
	return this;
};

DataWrapperContainer._get ::= DataWrapperContainer.getValue;
DataWrapperContainer._set ::= fn(key,value){
	this.setValue(key,value);
	return value;
};

DataWrapperContainer.getIterator ::= fn(){
	var mapIterator = this.dataWrappers.getIterator();

	var it = new ExtObject;
	it.end := mapIterator->mapIterator.end;
	it.next := mapIterator->mapIterator.next;
	it.key := mapIterator->mapIterator.key;
	it.value := mapIterator->fn(){
		var v = this.value();
		return v ? v() : void;
	};
	return it;

};

