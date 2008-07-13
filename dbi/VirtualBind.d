module dbi.VirtualBind;

import dbi.Database;

import ConvertInteger = tango.text.convert.Integer;
import ConvertFloat = tango.text.convert.Float;

size_t[] getParamIndices(char[] sql) {
	size_t[] paramIndices;
	auto len = sql.length;
	for(size_t i = 0; i < len; ++i)
	{
		if(sql[i] == '\?')
			paramIndices ~= i;
	}
	return paramIndices;
}

abstract class VirtualStatement : IStatement {
	this (SqlGenerator sqlGen, char[] sql) {
		this.sqlGen = sqlGen;
		this.sql = sql;
		this.paramIndices = getParamIndices(sql);
	}

	uint getParamCount()
	{
		return paramIndices.length;
	}
	
	void setParamTypes(BindType[] paramTypes)
	{
		this.paramTypes = paramTypes;
	}
	
	void setResultTypes(BindType[] resTypes)
	{
		this.resTypes = resTypes;
	}
	
	
	
	protected char[] virtualBind(void*[] bind)
	{
		/+size_t idx = 0;
		char[] execSql;
		foreach(i, type; paramTypes)
		{
			execSql ~= sql[idx .. paramIndices[i]];
			idx = paramIndices[i] + 1;
			switch(type)
			{
			case Bool:
				bool* ptr = cast(byte*)bind[i];
				if(*ptr) execSql ~= "1";
				else execSql ~= "0";
				break;
			case Byte:
				byte* ptr = cast(byte*)bind[i];
				execSql ~= ConvertInteger.toString(*ptr);
				break;
			case Short:
				short* ptr = cast(short*)bind[i];
				execSql ~= ConvertInteger.toString(*ptr);
				break;
			case Int:
				int* ptr = cast(int*)bind[i];
				execSql ~= ConvertInteger.toString(*ptr);
				break;
			case Long:
				long* ptr = cast(long*)bind[i];
				execSql ~= ConvertInteger.toString(*ptr);
				break;
			case UByte:
				ubyte* ptr = cast(ubyte*)bind[i];
				execSql ~= ConvertInteger.toString(*ptr);
				break;
			case UShort:
				ushort* ptr = cast(ushort*)bind[i];
				execSql ~= ConvertInteger.toString(*ptr);
				break;
			case UInt:
				uint* ptr = cast(uint*)bind[i];
				execSql ~= ConvertInteger.toString(*ptr);
				break;
			case ULong:
				ulong* ptr = cast(ulong*)bind[i];
				execSql ~= ConvertInteger.toString(*ptr);
				break;
			case Float:
				float* ptr = cast(float*)bind[i];
				execSql ~= ConvertFloat.toString(*ptr);
				break;
			case Double:
				double* ptr = cast(double*)bind[i];
				execSql ~= ConvertFloat.toString(*ptr);
				break;
			case String:
				char[]* ptr = cast(char[]*)bind[i];
				execSql ~= *ptr;
				assert(false, "String escaping");
				break;
			case Binary:
				ubyte[]* ptr = cast(void[]**)bind[i];
				execSql ~= sqlGen.createBinaryString(*ptr);
				break;
			case Time:
			case DateTime:
			case Null:
			default:
				assert(false, "Not implemented");
				break;
			}
		}
		execSql ~= sql[idx .. $];
		return execSql;+/
		assert(false);
		return null;
	}
	
	protected:
		SqlGenerator sqlGen;
		char[] sql;
		size_t[] paramIndices;
		BindType[] paramTypes;
		BindType[] resTypes;
}

char[] virtualBind(char[] sql, BindType[] paramTypes, void*[] ptrs, SqlGenerator sqlGen)
{
	auto paramIndices = getParamIndices(sql);
	return virtualBind(sql, paramIndices, paramTypes, ptrs, sqlGen);
}

char[] virtualBind(char[] sql, size_t[] paramIndices, BindType[] paramTypes, void*[] ptrs, SqlGenerator sqlGen)
{
	size_t idx = 0;
	char[] execSql;
	foreach(i, type; paramTypes)
	{
		execSql ~= sql[idx .. paramIndices[i]];
		idx = paramIndices[i] + 1;
		with(BindType)
		{
			switch(type)
			{
			case Bool:
				bool* ptr = cast(bool*)ptrs[i];
				if(*ptr) execSql ~= "1";
				else execSql ~= "0";
				break;
			case Byte:
				byte* ptr = cast(byte*)ptrs[i];
				execSql ~= ConvertInteger.toString(*ptr);
				break;
			case Short:
				short* ptr = cast(short*)ptrs[i];
				execSql ~= ConvertInteger.toString(*ptr);
				break;
			case Int:
				int* ptr = cast(int*)ptrs[i];
				execSql ~= ConvertInteger.toString(*ptr);
				break;
			case Long:
				long* ptr = cast(long*)ptrs[i];
				execSql ~= ConvertInteger.toString(*ptr);
				break;
			case UByte:
				ubyte* ptr = cast(ubyte*)ptrs[i];
				execSql ~= ConvertInteger.toString(*ptr);
				break;
			case UShort:
				ushort* ptr = cast(ushort*)ptrs[i];
				execSql ~= ConvertInteger.toString(*ptr);
				break;
			case UInt:
				uint* ptr = cast(uint*)ptrs[i];
				execSql ~= ConvertInteger.toString(*ptr);
				break;
			case ULong:
				ulong* ptr = cast(ulong*)ptrs[i];
				execSql ~= ConvertInteger.toString(*ptr);
				break;
			case Float:
				float* ptr = cast(float*)ptrs[i];
				execSql ~= ConvertFloat.toString(*ptr);
				break;
			case Double:
				double* ptr = cast(double*)ptrs[i];
				execSql ~= ConvertFloat.toString(*ptr);
				break;
			case String:
				char[]* ptr = cast(char[]*)ptrs[i];
				execSql ~= *ptr;
				assert(false, "String escaping");
				break;
			case Binary:
				ubyte[]* ptr = cast(ubyte[]*)ptrs[i];
				execSql ~= sqlGen.createBinaryString(*ptr);
				break;
			case Time:
			case DateTime:
			case Null:
			default:
				assert(false, "Not implemented");
				break;
			}
		}
	}
	execSql ~= sql[idx .. $];
	return execSql;
}