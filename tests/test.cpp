// test.cpp
// This file is part of the EScript programming language.
// See copyright notice in EScript.h
// ------------------------------------------------------
#ifdef ES_BUILD_TEST_APPLICATION
#include <cstdlib>
#include <iostream>
#include <string>

#include "../EScript/EScript.h"
#include "../EScript/Objects/ReferenceObject.h"

#ifdef ES_DEBUG_MEMORY
#include "../EScript/Compiler/Tokenizer.h"
#include "../EScript/Utils/Debug.h"
#endif

using namespace EScript;

// ---------------------------------------------------------
// test case for wrapped class

//! A simple test class with some data members
struct TestObject{
	int m1;
	float m2;
	explicit TestObject(int _m1,float _m2) : m1(_m1),m2(_m2){}
	bool operator==(const TestObject&other)const {	return m1==other.m1 && m2==other.m2;}
};

//! A EScript-container for the simple test class
struct E_TestObject : public ReferenceObject<TestObject>{
	ES_PROVIDES_TYPE_NAME(TestObject)
public:

	E_TestObject(int i=0,float f=0) :
			ReferenceObject<TestObject>(getTypeObject(),i,f){}
	virtual ~E_TestObject(){
//		std::cout << " ~TEST ";
	}
	TestObject & operator*(){				return ref();	}
	const TestObject & operator*()const{	return ref();	}

	static Type* getTypeObject(){
		static Type * typeObject = new Type(Object::getTypeObject()); // ---|> Object
		return typeObject;
	}
	//! (static)
	static void init(Namespace & ns){
		Type * typeObject = getTypeObject();
		declareConstant(&ns,getClassName(),typeObject);

		//! TestObject new TestObject([i [,j]])
		ESF_DECLARE(typeObject,"_constructor",0,2,new E_TestObject(parameter[0].to<int>(runtime),parameter[1].to<float>(runtime)))

		//! Number getM1()
		ESMF_DECLARE(typeObject,E_TestObject,"getM1",0,0,(**self).m1)

		//! Number getM2()
		ESMF_DECLARE(typeObject,E_TestObject,"getM2",0,0,(**self).m2)
		
		//! self setM1(Number)
		ESMF_DECLARE(typeObject,E_TestObject,"setM1",1,1,((**self).m1=parameter[0].to<int>(runtime),self))

		//! self setM2(Number)
		ESMF_DECLARE(typeObject,E_TestObject,"setM2",1,1,((**self).m2=parameter[0].to<float>(runtime),self))

	}
};

// ----------------------------------------------------------------------------

static const uint32_t INVALID_CODE_POINT = ~0;

static uint32_t readCodePoint_utf8(const char* &cursor,const char*utf8End){
	if(cursor >= utf8End )
		return INVALID_CODE_POINT;
	const uint8_t byte0 = static_cast<uint8_t>(*cursor);
	if(byte0<0x80){ // 1 byte
		++cursor;
		return static_cast<uint32_t>(byte0);
	}else if(byte0<0xE0){ // 2 byte sequence
		if(byte0<0xC2 || cursor+1 >= utf8End)
			return INVALID_CODE_POINT;
		const uint8_t byte1 = static_cast<uint8_t>(*(cursor+1));
		if( (byte1&0xC0) != 0x80 )
			return INVALID_CODE_POINT;
		cursor += 2;
		return	(static_cast<uint32_t>(byte0&0x1F) << 6) + (byte1&0x3F) ;
	}else if(byte0<0xF0){ // 3 byte sequence
		if(cursor+2 >= utf8End)
			return INVALID_CODE_POINT;
		const uint8_t byte1 = static_cast<uint8_t>(*(cursor+1));
		const uint8_t byte2 = static_cast<uint8_t>(*(cursor+2));
		if( (byte1&0xC0) != 0x80 || (byte2&0xC0) != 0x80 )
			return INVALID_CODE_POINT;
		cursor += 3;
		return	(static_cast<uint32_t>(byte0&0x0F) << 12) + 
				(static_cast<uint32_t>(byte1&0x3F) << 6) + 
				(byte2&0x3F) ;
	}else if(byte0<0xF5){ // 4 byte sequence
		if(cursor+3 >= utf8End)
			return INVALID_CODE_POINT;
		const uint8_t byte1 = static_cast<uint8_t>(*(cursor+1));
		const uint8_t byte2 = static_cast<uint8_t>(*(cursor+2));
		const uint8_t byte3 = static_cast<uint8_t>(*(cursor+3));
		if( (byte1&0xC0) != 0x80 || (byte2&0xC0) != 0x80 || (byte3&0xC0) != 0x80 )
			return INVALID_CODE_POINT;
		cursor += 4;
		return	(static_cast<uint32_t>(byte0&0x07) << 18) + 
				(static_cast<uint32_t>(byte1&0x3F) << 12) + 
				(static_cast<uint32_t>(byte2&0x3F) << 6) + 
				(byte3&0x3F);
	}else{
		return INVALID_CODE_POINT;
	}
}

//result readCodePoint_utf8(cursor, const char *utf8End,)

int main(int argc,char * argv[]) {

	std::string str ( u8"yä®€𝄞" );
	const char * cursor = str.c_str();
	std::cout << std::hex << readCodePoint_utf8( cursor,str.c_str()+str.length() )<<"\n";
	std::cout << std::hex << readCodePoint_utf8( cursor,str.c_str()+str.length() )<<"\n";
	std::cout << std::hex << readCodePoint_utf8( cursor,str.c_str()+str.length() )<<"\n";
	std::cout << std::hex << readCodePoint_utf8( cursor,str.c_str()+str.length() )<<"\n";
	std::cout << std::hex << readCodePoint_utf8( cursor,str.c_str()+str.length() )<<"\n";
	
//	UTF8InputStream in(str);
//	while(in.good()){
//		in.peek()
//	}
	
	EScript::init();

	// --- Init the TestObejct-Type
	E_TestObject::init(*EScript::getSGlobals());

#ifdef ES_DEBUG_MEMORY
	Tokenizer::identifyStaticToken(StringId()); // init constants
	Debug::clearObjects();
#endif

	ERef<Runtime> rt(new Runtime);

	declareConstant(rt->getGlobals(),"args",Array::create(argc,argv));

	// --- Load and execute script
	std::string file= argc>1 ? argv[1] : "tests/test.escript";
	std::pair<bool,ObjRef> result = EScript::loadAndExecute(*rt.get(),file);

	// --- output result
	if(result.second.isNotNull()) {
		std::cout << "\n\n --- "<<"\nResult: " << result.second.toString()<<"\n";
	}

	// --- cleanup
	result.second = nullptr;
	rt = nullptr;

#ifdef ES_DEBUG_MEMORY
	Debug::showObjects();
#endif
	return result.first ? EXIT_SUCCESS : EXIT_FAILURE;
}
#endif // ES_BUILD_TEST_APPLICATION
