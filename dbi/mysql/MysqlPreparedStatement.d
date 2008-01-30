module dbi.mysql.MysqlPreparedStatement;

version(dbi_mysql) {

	import tango.stdc.string;
	import tango.stdc.stringz : toDString = fromUtf8z, toCString = toStringz;
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
	
import dbi.mysql.MysqlDatabase;
version(Windows) {
	private import dbi.mysql.imp_win;
}
else {
	private import dbi.mysql.imp;
}
public import dbi.PreparedStatement, dbi.Metadata;

class MysqlPreparedStatementProvider : IPreparedStatementProvider, IMetadataProvider
{	
	this(MysqlDatabase db)
	{
		if(!db.connection) throw new Exception("Attempting to create prepared statements but not connected to database");
		mysql = db.connection;
	}
	
	private	MYSQL* mysql;
	
	IPreparedStatement prepare(char[] sql)
	{
		MYSQL_STMT* stmt = mysql_stmt_init(mysql);
		auto res = mysql_stmt_prepare(stmt, toCString(sql), sql.length);
		if(res != 0) {
			debug(Log) {
				auto err = mysql_stmt_error(stmt);
				log.error("Unable to create prepared statement: \"" ~ sql ~"\", errmsg: " ~ toDString(err));
			}
			return null;
		}
		return new MysqlPreparedStatement(stmt);
	}
	
	void beginTransact()
	{
		const char[] sql = "START TRANSACTION";
		mysql_real_query(mysql, sql.ptr, sql.length);
	}
	
	void rollback()
	{
		mysql_rollback(mysql);
	}
	
	void commit()
	{
		mysql_commit(mysql);
	}
	
	bool hasTable(char[] tablename)
	{
		MYSQL_RES* res = mysql_list_tables(mysql, toCString(tablename));
		if(!res) {
			debug(Log) {
				log.warn("mysql_list_tables returned null in method tableExists()");
				logError;
			}
			return false;
		}
		bool exists = mysql_fetch_row(res) ? true : false;
		mysql_free_result(res);
		return exists;
	}
	
	bool getTableInfo(char[] tablename, inout TableInfo info)
	{
		char[] q = "SHOW COLUMNS FROM `" ~ tablename ~ "`"; 
		auto ret = mysql_real_query(mysql, q.ptr, q.length);
		if(ret != 0) {
			debug(Log) {
				log.warn("Unable to SHOW COLUMNS for table " ~ tablename);
				logError;
			}
			return false;
		}
		MYSQL_RES* res = mysql_store_result(mysql);
		if(!res) {
			debug(Log) {
				log.warn("Unable to store result for " ~ q);
				logError;
			}
			return false;
		}
		if(mysql_num_fields(res) < 1) {
			debug(Log)
			log.warn("Result stored, but query " ~ q ~ " has no fields");
			return false;
		}
		info.fieldNames = null;
		MYSQL_ROW row = mysql_fetch_row(res);
		while(row != null) {
			char[] dbCol = toDString(row[0]).dup;
			info.fieldNames ~= dbCol;
			char[] keyCol = toDString(row[3]);
			if(keyCol == "PRI") info.primaryKeyFields ~= dbCol;
			row = mysql_fetch_row(res);
		}
		mysql_free_result(res);
		return true;
	}
	
	debug(Log)
	{
		static Logger log;
		static this()
		{
			log = Log.getLogger("dbi.mysql.MysqlPreparedStatement.MysqlPreparedStatementProvider");
		}
		
		private void logError()
		{
			char* err = mysql_error(mysql);
			log.trace(toDString(err));
		}
	}
}

class MysqlPreparedStatement : IPreparedStatement
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
		FieldInfo[] metadata;
		
		metadata.length = nFields;
		
		for(uint i = 0; i < nFields; i++)
		{
			metadata[i].name = fields[i].name[0 .. fields[i].name_length].dup;
			metadata[i].type = fromMysqlType(fields[i].type, fields[i].flags);
		}
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
	
	bool execute()
	{
		return mysql_stmt_execute(stmt) == 0 ? true : false;
	}
	
	bool execute(void*[] bind)
	{
		if(!bind || !paramBind) throw new Exception("Attempting to execute a statement without having set parameters types or based a valid bind array.");
		if(bind.length != paramBind.length) throw new Exception("Incorrect number of pointers in bind array");
		
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
		
		auto res = mysql_stmt_bind_param(stmt, paramBind.ptr);
		if(res != 0) return false;
		res = mysql_stmt_execute(stmt);
		return res == 0 ? true : false;
	}
	
	bool fetch(void*[] bind)
	{
		if(!bind || !resBind) throw new Exception("Attempting to fetch from a statement without having set parameters types or based a valid bind array.");
		if(bind.length != resBind.length) throw new Exception("Incorrect number of pointers in bind array");
		
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
				ubyte[] buf;
				buf.length = 255;
				resHelper.buffer[i] = buf;
				resBind[i].buffer = buf.ptr;
				resBind[i].buffer_length = 255;
				resHelper.len[i] = 255;
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
					buf.length = l;
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
	
	private this(MYSQL_STMT* stmt)
	{
		this.stmt = stmt;
	}
	
	~this()
	{
		mysql_stmt_close(stmt);
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
	
	private static BindType fromMysqlType(enum_field_types type, uint flags)
	{
		bool unsigned = flags & UNSIGNED_FLAG ? true : false;
		with(enum_field_types) {
		with(BindType) {
			switch(type)
			{
			case MYSQL_TYPE_BIT:
				return Bool;
			case MYSQL_TYPE_TINY:
				return unsigned ? UByte : Byte;
            case MYSQL_TYPE_SHORT:
            	return unsigned ? UShort : Short;
            case MYSQL_TYPE_LONG:
            case MYSQL_TYPE_INT24:
            	return unsigned ? UInt : Int;
            case MYSQL_TYPE_LONGLONG:
            	return unsigned ? ULong : Long;
			case MYSQL_TYPE_DECIMAL:
            case MYSQL_TYPE_FLOAT:
            	return Float;
            case MYSQL_TYPE_DOUBLE:
            	return Double;
            case MYSQL_TYPE_TIMESTAMP:
            case MYSQL_TYPE_DATE:
            case MYSQL_TYPE_TIME:
            case MYSQL_TYPE_DATETIME:
            	return DateTime;
            case MYSQL_TYPE_VAR_STRING:
            case MYSQL_TYPE_STRING:
            case MYSQL_TYPE_VARCHAR:
            	return String;
            case MYSQL_TYPE_NULL:
            	return Null;
            case MYSQL_TYPE_TINY_BLOB:
            case MYSQL_TYPE_MEDIUM_BLOB:
            case MYSQL_TYPE_LONG_BLOB:
            case MYSQL_TYPE_BLOB:
            	return Binary;  	
            case MYSQL_TYPE_YEAR:
            case MYSQL_TYPE_NEWDATE:
            case MYSQL_TYPE_NEWDECIMAL:
            case MYSQL_TYPE_ENUM:
            case MYSQL_TYPE_SET:
			case MYSQL_TYPE_GEOMETRY:
			default:
				debug assert(false, "Unsupported type");
				return Null;
			}
		}
		}
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
debug(UnitTest) {

unittest
{
	Log.getRootLogger.addAppender(new ConsoleAppender);
	
	MysqlDatabase db = new MysqlDatabase();
	db.connect("dbname=test", "test", "test");
	auto provider = new MysqlPreparedStatementProvider(db);
	auto st = provider.prepare("SELECT * FROM test WHERE 1");
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
	assert(st.execute);
	assert(st.fetch(bind));
	Stdout.formatln("id:{},name:{},dateofbirth:{}",id,name,dateofbirth.ticks);
	assert(!st.fetch(bind));
	
	auto st2 = provider.prepare("SELECT * FROM test WHERE id = \?");
	assert(st2);
	BindType[] paramTypes;
	void*[] pBind;
	ushort usID = 1;
	paramTypes ~= BindType.UShort;
	st2.setParamTypes(paramTypes);
	st2.setResultTypes(resTypes);
	pBind ~= &usID;
	assert(st2.execute(pBind));
	assert(st2.fetch(bind));
	Stdout.formatln("id:{},name:{},dateofbirth:{}",id,name,dateofbirth.ticks);
	st2.reset;
	
	assert(provider.hasTable("test"));
	TableInfo ti;
	assert(provider.getTableInfo("test", ti));
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
}

}
}
