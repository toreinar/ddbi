module dbi.mysql.MysqlPreparedStatement;

version(dbi_mysql) {

	import tango.stdc.string;
	import tango.stdc.stringz : toDString = fromStringz, toCString = toStringz;
	static import tango.text.Util;
	import Integer = tango.text.convert.Integer;
	debug(UnitTest) {
		import tango.stdc.stringz;
		import tango.io.Stdout;
		debug = Log;
	}
	debug(Log) {
		import tango.util.log.ConsoleAppender;
		import tango.util.log.Log;
	}
	
import dbi.DBIException, dbi.mysql.MysqlError;
version(Windows) {
	private import dbi.mysql.imp_win;
}
else {
	private import dbi.mysql.imp;
}
public import dbi.Statement;
import dbi.mysql.MysqlMetadata;

class MysqlPreparedStatement : IStatement
{
	uint getParamCount()
	{
		return mysql_stmt_param_count(stmt);
	}
	
	FieldInfo[] getResultMetadata()
	{
		MYSQL_RES* res = mysql_stmt_result_metadata(stmt);
		if(!res) return null;
		uint nFields = mysql_num_fields(res);
		if(!nFields) return null;
		
		MYSQL_FIELD* fields = mysql_fetch_fields(res);
		
		auto metadata = getFieldMetadata(fields[0..nFields]);
		
		mysql_free_result(res);
		return metadata;
	}
	
	void setParamTypes(BindType[] paramTypes)
	{
		initBindings(paramTypes, paramBind, paramHelper);
	}
	
	void setResultTypes(BindType[] resTypes)
	{
		initBindings(resTypes, resBind, resHelper);
	}
	
	void execute()
	{
		auto res = mysql_stmt_execute(stmt);
		if(res != 0) {
			throw new DBIException("Error at mysql_stmt_execute.", res, specificToGeneral(res));
		}
	}
	
	void execute(void*[] bind)
	{
		if(!bind || !paramBind) throw new DBIException("Attempting to execute a statement without having set parameters types or passed a valid bind array.");
		if(bind.length != paramBind.length) throw new DBIException("Incorrect number of pointers in bind array");
		
		uint len = bind.length;
		for(uint i = 0; i < len; ++i)
		{
			switch(paramHelper.types[i])
			{
			case(BindType.String):
			case(BindType.Binary):
				ubyte[]* arr = cast(ubyte[]*)(bind[i]);
				paramBind[i].buffer = (*arr).ptr;
				auto l = (*arr).length;
				paramBind[i].buffer_length = l;
				paramHelper.len[i] = l;
				break;
			case(BindType.Time):
				auto time = *cast(Time*)(bind[i]);
				auto dateTime = Clock.toDate(time); 
				paramHelper.time[i].year = dateTime.date.year;
				paramHelper.time[i].month = dateTime.date.month;
				paramHelper.time[i].day = dateTime.date.day;
				paramHelper.time[i].hour = dateTime.time.hours;
				paramHelper.time[i].minute = dateTime.time.minutes;
				paramHelper.time[i].second = dateTime.time.seconds;
				break;
			case(BindType.DateTime):
				auto dateTime = *cast(DateTime*)(bind[i]);
				paramHelper.time[i].year = dateTime.date.year;
				paramHelper.time[i].month = dateTime.date.month;
				paramHelper.time[i].day = dateTime.date.day;
				paramHelper.time[i].hour = dateTime.time.hours;
				paramHelper.time[i].minute = dateTime.time.minutes;
				paramHelper.time[i].second = dateTime.time.seconds;
				break;
			default:
				paramBind[i].buffer = bind[i];
				break;
			}
		}
		
		int res = mysql_stmt_bind_param(stmt, paramBind.ptr);
		if(res != 0) {
			throw new DBIException("Error at mysql_stmt_bind_param.", res, specificToGeneral(res));
		}
		res = mysql_stmt_execute(stmt);
		if(res != 0) {
			debug Stdout.formatln("mysql_stmt_errno:{}", mysql_stmt_errno(stmt));
			debug Stdout.formatln("mysql_stmt_error:{}", toDString(mysql_stmt_error(stmt)));
			throw new DBIException("Error at mysql_stmt_execute.", res, specificToGeneral(res));
		}
	}
	
	bool fetch(void*[] bind, void* delegate(size_t) allocator = null)
	{
		if(!bind || !resBind) throw new DBIException("Attempting to fetch from a statement without having set parameters types or passed a valid bind array.");
		if(bind.length != resBind.length) throw new DBIException("Incorrect number of pointers in bind array");
		
		uint len = bind.length;
		for(uint i = 0; i < len; ++i)
		{
			with(enum_field_types)
			{
			switch(resBind[i].buffer_type)
			{
			case(MYSQL_TYPE_STRING):
			case(MYSQL_TYPE_BLOB):
				/*ubyte[]* arr = cast(ubyte[]*)(bind[i]);
				(*arr).length = 256;
				resBind[i].buffer_length = 256;
				resHelper.len[i] = 256;
				resBind[i].buffer = (*arr).ptr;*/
				/*ubyte[] buf;
				buf.length = 0;
				resHelper.buffer[i] = buf;
				resBind[i].buffer = buf.ptr;
				resBind[i].buffer_length = 0;
				resHelper.len[i] = 0;*/
				ubyte[]* arr = cast(ubyte[]*)(bind[i]);
				resHelper.buffer[i] = *arr;
				resBind[i].buffer_length = arr.length;
				resHelper.len[i] = 0;
				resBind[i].buffer = arr.ptr;
				break;
			case(MYSQL_TYPE_DATETIME):
				break;
			default:
				resBind[i].buffer = bind[i];
				break;
			}
			}
		}
		
		my_bool bres = mysql_stmt_bind_result(stmt, resBind.ptr);
		if(bres != 0) {
			debug(Log) {
				log.error("Unable to bind result params");
				logError;
			}
			return false;
		}
		int res = mysql_stmt_fetch(stmt);
		if(res == 1) {
			debug(Log) {
				log.error("Error fetching result data");
				logError;
			}
			return false;
		}
		if(res == MYSQL_NO_DATA) {
			reset;
			return false;
		}
		
		foreach(i, mysqlTime; resHelper.time)
		{
			if(resHelper.types[i] == BindType.Time) {
				Time* time = cast(Time*)(bind[i]);
				DateTime dt;
				dt.date.year = mysqlTime.year;
				dt.date.month = mysqlTime.month;
				dt.date.day = mysqlTime.day;
				dt.time.hours = mysqlTime.hour;
				dt.time.minutes = mysqlTime.minute;
				dt.time.seconds = mysqlTime.second;
				*time = Clock.fromDate(dt);
			}
			else if(resHelper.types[i] == BindType.DateTime) {
				DateTime* dt = cast(DateTime*)(bind[i]);
				(*dt).date.year = mysqlTime.year;
				(*dt).date.month = mysqlTime.month;
				(*dt).date.day = mysqlTime.day;
				(*dt).time.hours = mysqlTime.hour;
				(*dt).time.minutes = mysqlTime.minute;
				(*dt).time.seconds = mysqlTime.second;
			}
		}
		
		if(res == 0) {
			foreach(i, buf; resHelper.buffer)
			{
				ubyte[]* arr = cast(ubyte[]*)(bind[i]);
				uint l = resHelper.len[i];
				*arr = buf[0 .. l];
			}
			return true;
		}
		else if(res == MYSQL_DATA_TRUNCATED)
		{
			foreach(i, buf; resHelper.buffer)
			{
				ubyte[]* arr = cast(ubyte[]*)(bind[i]);
				uint l = resHelper.len[i];
				
				if(resBind[i].error) {
					if(allocator) {
						ubyte* ptr = cast(ubyte*)allocator(l);
						buf = ptr[0 .. l];
					}
					else {
						buf = new ubyte[l];
					}
					resBind[i].buffer_length = l;
					resBind[i].buffer = buf.ptr;
					if(mysql_stmt_fetch_column(stmt, &resBind[i], i, 0) != 0) {
						debug(Log) {
							log.error("Error fetching String of Binary that failed due to truncation");
							logError;
						}
						return false;
					}
				}
				*arr = buf[0 .. l];
			}
			return true;
		}
		else if(res == MYSQL_NO_DATA) return false;
		else return false;
	}
	
	void prefetchAll()
	{
		mysql_stmt_store_result(stmt);
	}
	
	void reset()
	{
		mysql_stmt_free_result(stmt);
	}
	
	ulong getLastInsertID()
	{
		return mysql_stmt_insert_id(stmt);
	}
	
	char[] getLastErrorMsg()
	{
		return toDString(mysql_stmt_error(stmt));
	}
	
	package this(MYSQL_STMT* stmt)
	{
		this.stmt = stmt;
	}
	
	void close()
	{
		if (stmt !is null) {
	        mysql_stmt_close(stmt);
	        stmt = null;
	    }
	}
	
	~this()
	{
        close;
	}
	
	private MYSQL_STMT* stmt;
	private MYSQL_BIND[] paramBind;
	private BindingHelper paramHelper;
	private MYSQL_BIND[] resBind;
	private BindingHelper resHelper;
	
	private static struct BindingHelper
	{	
		void setLength(size_t l)
		{
			error.length = l;
			is_null.length = l;
			len.length = l;
			time = null;
			buffer = null;
			foreach(ref n; is_null)
			{
				n = false;
			}
			
			foreach(ref e; error)
			{
				e = false;
			}
			
			foreach(ref i; len)
			{
				i = 0;
			}
		}
		my_bool[] error;
		my_bool[] is_null;
		uint[] len;
		MYSQL_TIME[uint] time;
		ubyte[][uint] buffer;
		BindType[] types;
	}
	
	private static void initBindings(BindType[] types, inout MYSQL_BIND[] bind, inout BindingHelper helper)
	{
		size_t l = types.length;
		bind.length = l;
		foreach(ref b; bind)
		{
			memset(&b, 0, MYSQL_BIND.sizeof);
		}
		helper.setLength(l);
		for(size_t i = 0; i < l; ++i)
		{
			switch(types[i])
			{
			case(BindType.Bool):
				bind[i].buffer_type = enum_field_types.MYSQL_TYPE_TINY;
				bind[i].is_unsigned = false;
				break;
			case(BindType.Byte):
				bind[i].buffer_type = enum_field_types.MYSQL_TYPE_TINY;
				bind[i].is_unsigned = false;
				break;
			case(BindType.Short):
				bind[i].buffer_type = enum_field_types.MYSQL_TYPE_SHORT;
				bind[i].is_unsigned = false;
				break;
			case(BindType.Int):
				bind[i].buffer_type = enum_field_types.MYSQL_TYPE_LONG;
				bind[i].buffer_length = 4;
				bind[i].is_unsigned = false;
				break;
			case(BindType.Long):
				bind[i].buffer_type = enum_field_types.MYSQL_TYPE_LONGLONG;
				bind[i].buffer_length = 8;
				bind[i].is_unsigned = false;
				break;
			case(BindType.UByte):
				bind[i].buffer_type = enum_field_types.MYSQL_TYPE_TINY;
				bind[i].is_unsigned = true;
				break;
			case(BindType.UShort):
				bind[i].buffer_type = enum_field_types.MYSQL_TYPE_SHORT;
				bind[i].is_unsigned = true;
				break;
			case(BindType.UInt):
				bind[i].buffer_type = enum_field_types.MYSQL_TYPE_LONG;
				bind[i].buffer_length = 4;
				bind[i].is_unsigned = true;
				break;
			case(BindType.ULong):
				bind[i].buffer_type = enum_field_types.MYSQL_TYPE_LONGLONG;
				bind[i].buffer_length = 8;
				bind[i].is_unsigned = true;
				break;
			case(BindType.Float):
				bind[i].buffer_type = enum_field_types.MYSQL_TYPE_FLOAT;
				bind[i].is_unsigned = false;
				break;
			case(BindType.Double):
				bind[i].buffer_type = enum_field_types.MYSQL_TYPE_DOUBLE;
				bind[i].is_unsigned = false;
				break;
			case(BindType.String):
				bind[i].buffer_type = enum_field_types.MYSQL_TYPE_STRING;
				bind[i].is_unsigned = false;
				break;
			case(BindType.Binary):
				bind[i].buffer_type = enum_field_types.MYSQL_TYPE_BLOB;
				bind[i].is_unsigned = false;
				break;
			case(BindType.Time):
				helper.time[i] = MYSQL_TIME();
				bind[i].buffer = &helper.time[i];
				bind[i].buffer_type = enum_field_types.MYSQL_TYPE_DATETIME;
				bind[i].is_unsigned = false;
				break;
			case(BindType.DateTime):
				helper.time[i] = MYSQL_TIME();
				bind[i].buffer = &helper.time[i];
				bind[i].buffer_type = enum_field_types.MYSQL_TYPE_DATETIME;
				bind[i].is_unsigned = false;
				break;
			case(BindType.Null):
				bind[i].buffer_type = enum_field_types.MYSQL_TYPE_NULL;
				break;
			default:
				debug assert(false, "Unhandled bind type"); //TODO more detailed information;
				bind[i].buffer_type = enum_field_types.MYSQL_TYPE_NULL;
				break;
			}
			
			bind[i].length = &helper.len[i];
			bind[i].error = &helper.error[i];
			bind[i].is_null = &helper.is_null[i];
		}
		
		helper.types = types;
	}
	
	debug(Log)
	{
		static Logger log;
		static this()
		{
			log = Log.getLogger("dbi.mysql.MysqlPreparedStatement.MysqlPreparedStatement");
		}
		
		private void logError()
		{
			char* err = mysql_stmt_error(stmt);
			log.trace(toDString(err));
		}
	}
}
/+
debug(UnitTest) {
	
import dbi.Registry;

unittest
{
	Log.getRootLogger.addAppender(new ConsoleAppender);
	
	//auto db = new MysqlDatabase("localhost", null, "test", "username=test&password=test");
	auto db = getDatabaseForURL("mysql://localhost/test?username=test&password=test");
	auto st = db.prepare("SELECT * FROM test WHERE 1");
	assert(st);
	assert(st.getParamCount == 0);
	st.execute();
	auto metadata = st.getResultMetadata();
	foreach(f; metadata)
	{
		Stdout.formatln("Name:{}, Type:{}", f.name, f.type);
	}
	uint id;
	char[] name;
	Time dateofbirth;
	BindType[] resTypes;
	resTypes ~= BindType.UInt;
	resTypes ~= BindType.String;
	resTypes ~= BindType.Time;
	st.setResultTypes(resTypes);
	void*[] bind;
	bind.length = 3;
	bind[0] = &id;
	bind[1] = &name;
	bind[2] = &dateofbirth;
	st.execute;
	assert(st.fetch(bind));
	Stdout.formatln("id:{},name:{},dateofbirth:{}",id,name,dateofbirth.ticks);
	assert(!st.fetch(bind));
	
	auto st2 = db.prepare("SELECT * FROM test WHERE id = \?");
	assert(st2);
	BindType[] paramTypes;
	void*[] pBind;
	ushort usID = 1;
	paramTypes ~= BindType.UShort;
	st2.setParamTypes(paramTypes);
	st2.setResultTypes(resTypes);
	pBind ~= &usID;
	st2.execute(pBind);
	assert(st2.fetch(bind));
	Stdout.formatln("id:{},name:{},dateofbirth:{}",id,name,dateofbirth.ticks);
	st2.reset;
	
	assert(db.hasTable("test"));
	TableInfo ti;
	assert(db.getTableInfo("test", ti));
	assert(ti.fieldNames.length == 3);
	assert(ti.primaryKeyFields.length == 1);
	foreach(f; ti.fieldNames)
	{
		Stdout.formatln("Field Name:{}", f);
	}
	
	foreach(f; ti.primaryKeyFields)
	{
		Stdout.formatln("Primary Key:{}", f);
	}
	
	db.close;
	
	assert(false);
}

}
+/
}