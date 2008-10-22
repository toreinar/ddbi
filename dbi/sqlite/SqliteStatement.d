module dbi.sqlite.SqliteStatement;

import dbi.Statement, dbi.DBIException;
import tango.stdc.stringz : toDString = fromStringz, toCString = toStringz;
import Integer = tango.text.convert.Integer;
import tango.core.Traits;

import DT = tango.time.Time;
import tango.time.chrono.Gregorian;
import dbi.util.DateTime;

import dbi.sqlite.SqliteError;
import dbi.sqlite.imp;

import tango.stdc.string;

debug import tango.io.Stdout;
debug import tango.util.log.Log;

class SqliteStatement : IStatement
{
	uint getParamCount()
	{
		return cast(uint)sqlite3_bind_parameter_count(stmt);
	}
	
	FieldInfo[] getResultMetadata()
	{
		auto fieldCount = sqlite3_column_count(stmt);
		FieldInfo[] fieldInfo;
		for(int i = 0; i < fieldCount; ++i)
		{
			FieldInfo info;
			
			info.name = toDString(sqlite3_column_name(stmt, i));
			info.type = fromSqliteType(sqlite3_column_type(stmt, i));
			
			fieldInfo ~= info;
		}
		
		return fieldInfo;
	}
	
	void setParamTypes(BindType[] paramTypes)
	{
		this.paramTypes = paramTypes;
	}
	
	void setResultTypes(BindType[] resTypes)
	{
		this.resTypes = resTypes;
	}
	
	void execute()
	{
		debug log.info("Executing {}", sql);
		lastRes = sqlite3_step(stmt);
		wasReset = false;
		if(lastRes != SQLITE_ROW && lastRes != SQLITE_DONE)
			throw new DBIException("sqlite3_step error: " ~ toDString(sqlite3_errmsg(sqlite)),
				sql, lastRes, specificToGeneral(lastRes));
	}
	
	void execute(void*[] ptrs)
	{
		auto len = paramTypes.length;
		if(ptrs.length != len)
			throw new DBIException("ptrs array is not the same size as paramTypes array in SqliteStatement.execute", sql);
		
		for(size_t i = 0; i < len; ++i)
		{
			bind!(true)(stmt, paramTypes[i], ptrs[i], i);
		}
		
		execute;
	}
	
	bool fetch(void*[] ptrs, void* delegate(size_t) allocator = null)
	{
		if(lastRes != SQLITE_ROW)
			return false;
		
		auto len = resTypes.length;
		if(ptrs.length != len)
			throw new DBIException("ptrs array is not the same size as resTypes array in SqliteStatement.fetch", sql);
		
		for(size_t i = 0; i < len; ++i)
		{
			bind!(false)(stmt, resTypes[i], ptrs[i], i, allocator);
		}
		
		lastRes = sqlite3_step(stmt);
		wasReset = false;
		return true;
	}
	
	static void bindT(T, bool P)(sqlite3_stmt* stmt, void* ptr, int index, void* delegate(size_t) allocator = null)
	{
		T* val = cast(T*)ptr;
		static if(isIntegerType!(T) || is(T == bool))
		{
			static if(is(Int == long) || is(Int == uint) || is(Int == ulong))
			{
				static if(P) sqlite3_bind_int64(stmt, index + 1, cast(long)*val);
				else *val = cast(T)sqlite3_column_int64(stmt, index);
			}
			else
			{
				static if(P) sqlite3_bind_int(stmt, index + 1, cast(int)*val);
				else *val = cast(T)sqlite3_column_int(stmt, index);
			}
		}
		else static if(isRealType!(T))
		{
			static if(P) sqlite3_bind_double(stmt, index + 1, cast(double)*val);
			else *val = cast(T)sqlite3_column_double(stmt, index);
		}
		else static if(is(T == char[]))
		{
			static if(P) sqlite3_bind_text(stmt, index + 1, val.ptr, val.length, null);
			else {
				auto res = sqlite3_column_text(stmt, index);
				auto len = sqlite3_column_bytes(stmt, index);
				/+if(allocator !is null) {
					*val = (cast(char*)allocator(len)[0 .. len]);
					strncpy(val.ptr, res, len);
				}
				else *val = res[0 .. len].dup;+/
				*val = res[0 .. len].dup;
			}
		}
		else static if(is(T == void[]) || is(T == ubyte[]))
		{
			static if(P) sqlite3_bind_blob(stmt, index + 1, val.ptr, val.length, null);
			else {
				auto res = sqlite3_column_blob(stmt, index);
				auto len = sqlite3_column_bytes(stmt, index);
				*val = res[0 .. len].dup;
			}
		}
		else static if(is(T == DT.DateTime) || is(T == DT.Time))
		{
			static if(P) {
				auto txt = new char[19];
				
				static if(is(T == DT.DateTime)) {
					txt = printDateTime(*val, txt);
				}
				else static if(is(T == DT.Time)) {
					DT.DateTime dt;
					//auto dt = Clock.toDate(*val);
					Gregorian.generic.split(*val, dt.date.year, dt.date.month, 
						dt.date.day, dt.date.doy, dt.date.dow, dt.date.era);
					dt.time = (*val).time;
					txt = printDateTime(dt, txt);
				}
				else static assert(false);
				
				sqlite3_bind_text(stmt, index + 1, txt.ptr, txt.length, null); //TODO add destructor for txt
			}
			else {
				auto res = sqlite3_column_text(stmt, index);
				auto len = sqlite3_column_bytes(stmt, index);
				auto src = res[0 .. len];
				
				static if(is(T == DT.DateTime)) {
					 parseDateTime(res[0 .. len], *(cast(DT.DateTime*)ptr));
				}
				else static if(is(T == DT.Time)) {
					DT.DateTime dt;
					parseDateTime(res[0 .. len], dt);
					//*(cast(Time*)ptr) = Clock.fromDate(dt);
					*(cast(Time*)ptr) = Gregorian.generic.toTime(dt);
				}
				else static assert(false);
			}
		}
		else static assert(false, "Unsupported Sqlite bind type " ~ T.stringof);
	}
	
	static void bindNull(bool P)(sqlite3_stmt* stmt, int index)
	{
		static if(P) sqlite3_bind_null(stmt, index + 1);
	}
	
	static void bind(bool P)(sqlite3_stmt* stmt, BindType type, void* ptr, int index, void* delegate(size_t) allocator = null)
	{
		with(BindType)
		{
			switch(type)
			{
			case Bool:
				bindT!(bool, P)(stmt, ptr, index, allocator);
				break;
			case Byte:
				bindT!(byte, P)(stmt, ptr, index, allocator);
				break;
			case Short:
				bindT!(short, P)(stmt, ptr, index, allocator);
				break;
			case Int:
				bindT!(int, P)(stmt, ptr, index, allocator);
				break;
			case Long:
				bindT!(long, P)(stmt, ptr, index, allocator);
				break;
			case UByte:
				bindT!(ubyte, P)(stmt, ptr, index, allocator);
				break;
			case UShort:
				bindT!(ushort, P)(stmt, ptr, index, allocator);
				break;
			case UInt:
				bindT!(uint, P)(stmt, ptr, index, allocator);
				break;
			case ULong:
				bindT!(ulong, P)(stmt, ptr, index, allocator);
				break;
			case Float:
				bindT!(float, P)(stmt, ptr, index, allocator);
				break;
			case Double:
				bindT!(double, P)(stmt, ptr, index, allocator);
				break;
			case String:
				bindT!(char[], P)(stmt, ptr, index, allocator);
				break;
			case Binary:
				bindT!(void[], P)(stmt, ptr, index, allocator);
				break;
			case Time:
				bindT!(DT.Time, P)(stmt, ptr, index, allocator);
				break;
			case DateTime:
				bindT!(DT.DateTime, P)(stmt, ptr, index, allocator);
				break;
			case Null:
				bindNull!(P)(stmt, index);
				break;
			default:
				debug assert(false, "Unhandled bind type " ~ Integer.toString(type)); //TODO more detailed information;
				bindNull!(P)(stmt, index);
				break;
			}
		}
	}
	
	void prefetchAll()
	{
	}
	
	void reset()
	{
		if(!wasReset) {
			sqlite3_reset(stmt);
			wasReset = true;
			lastRes = SQLITE_DONE;
		}
	}
	
	ulong getLastInsertID()
	{
		long id = sqlite3_last_insert_rowid(sqlite);
		if(id == 0)	return 0;
		else return cast(ulong)id;
	}
	
	package this(sqlite3* sqlite, sqlite3_stmt* stmt, char[] sql, SqliteStatement lastSt)
	{
		this.sqlite = sqlite;
		this.stmt = stmt;
		this.sql = sql;
		this.lastSt = lastSt;
	}
	
	void close()
	{
		if (stmt !is null) {
			sqlite3_finalize(stmt);
			stmt = null;
		}
	}
	
	~this()
	{
		close;
	}
	
	private int lastRes;
	private bool wasReset = false;
	
	private sqlite3* sqlite;
	private sqlite3_stmt* stmt;
	private char[] sql;
	package SqliteStatement lastSt; // Used as a linked list ensuring that all statements are closed when the connection is closed
	
	private BindType[] paramTypes;
	private BindType[] resTypes;
	
	static BindType fromSqliteType(int type)
	{
		with(BindType) {
			switch(type)
			{
			case SQLITE_INTEGER:
				return Long;
			case SQLITE_FLOAT:
				return Double;
            case SQLITE_TEXT:
            	return String;
            case SQLITE_BLOB:
            	return Binary;
            case SQLITE_NULL:
            	return Null;
			default:
				debug assert(false, "Unsupported type");
				return Null;
			}
		}
	}
	
	debug
	{
		static Logger log;
		static this()
		{
			log = Log.lookup("dbi.sqlite.Sqlite");
		}
	}
}