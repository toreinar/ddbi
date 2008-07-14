﻿/**
 * Authors: The D DBI project
 * Copyright: BSD license
 */
module dbi.mysql.MysqlDatabase;

version=dbi_mysql;
version (dbi_mysql) {

private import tango.stdc.stringz : toDString = fromStringz, toCString = toStringz;
private import tango.io.Console;
private static import tango.text.Util;
private static import tango.text.convert.Integer;
debug(UnitTest) import tango.io.Stdout;

public import dbi.Database;
private import dbi.DBIException, dbi.Statement, dbi.Registry;
private import dbi.VirtualStatement;
version(Windows) {
	private import dbi.mysql.imp_win;
}
else {
	private import dbi.mysql.imp;
}
private import dbi.mysql.MysqlError, dbi.mysql.MysqlPreparedStatement, dbi.mysql.MysqlVirtualStatement;
import tango.text.Util;

import dbi.util.StringWriter;

static this() {
	uint ver = mysql_get_client_version();
	if(ver < 50000) {
		throw new Exception("Unsupported MySQL client version.  Please compile using at least version 5.0 of the MySQL client libray.");
	}
	else if(ver < 50100) {
		if(MYSQL_VERSION != 50000) {
			throw new Exception("You are linking against version 5.0 of the MySQL client library but you have a build switch turned on for a different version (such as MySQL_51).");
		}
	}
	else {
		if(MYSQL_VERSION != 50100) {
			throw new Exception("You are linking against version 5.1 (or higher) of the MySQL client library so you need to use the build switch '-version=MySQL_51'.");
		}
	}
}

/**
 * An implementation of Database for use with MySQL databases.
 *
 * Bugs:
 *	Column types aren't retrieved.
 *
 * See_Also:
 *	Database is the interface that this provides an implementation of.
 */
class MysqlDatabase : Database, IMetadataProvider {
	public:
	/**
	 * Create a new instance of MysqlDatabase, but don't connect.
	 */
	this () {
		mysql = mysql_init(null);
	}

	/**
	 * Create a new instance of MysqlDatabase and connect to a server.
	 *
	 * See_Also:
	 *	connect
	 */
	this (char[] host, char[] port, char[] dbname, char[] params) {
		this();
		connect(host, port, dbname, params);
	}

	/**
	 * Connect to a database on a MySQL server.
	 *
	 * Params:
	 *  host = The host name of the database to _connect to.
	 *  port = The port number to _connect to or null to use the default host. 
	 *  dbname = The name of the database to use.
	 *	params = A string in the form "keyword1=value1&keyword2=value2;etc."
	 *	
	 *
	 * Keywords:

	 *  username = The _username to _connect with.
	 *	password = The _password to _connect with.
	 *	sock = The socket to _connect to.
	 *
	 * Throws:
	 *	DBIException if there was an error connecting.
	 *
	 *	DBIException if port is provided but is not an integer.
	 *
	 * Examples:
	 *	---
	 *	MysqlDatabase db = new MysqlDatabase();
	 *	db.connect("localhost", null, "test", "username=bob&password=12345");
	 *	---
	 */	
	void connect(char[] host, char[] port, char[] dbname, char[] params)
	{
		char[] sock = null;
		char[] username = null;
		char[] password = null;
		uint portNo = 0;
		if(port.length) portNo = cast(uint)tango.text.convert.Integer.parse(port);

		void parseKeywords () {
			char[][char[]] keywords = getKeywords(params, "&");
			if ("username" in keywords) {
				username = keywords["username"];
				Stdout.formatln("Username={}", username);
			}
			if ("password" in keywords) {
				password = keywords["password"];
				Stdout.formatln("Password={}", password);
			}
			if ("sock" in keywords) {
				sock = keywords["sock"];
				Stdout.formatln("Username={}", username);
			}
		}
		
		parseKeywords;

		mysql_real_connect(mysql, toCString(host), toCString(username), toCString(password), toCString(dbname), portNo, toCString(sock), 0);
		if (uint error = mysql_errno(mysql)) {
		        Cout("connect(): ");
		        Cout(toDString(mysql_error(mysql)));
		        Cout("\n").flush;			
			throw new DBIException("Unable to connect to the MySQL database.", error, specificToGeneral(error));
		}
	}

	/**
	 * Close the current connection to the database.
	 *
	 * Throws:
	 *	DBIException if there was an error disconnecting.
	 */
	override void close () {
		if (mysql !is null) {
			mysql_close(mysql);
			if (uint error = mysql_errno(mysql)) {
   		                Cout("close(): ");
		                Cout(toDString(mysql_error(mysql)));
		                Cout("\n").flush;			
				throw new DBIException("Unable to close the MySQL database.", error, specificToGeneral(error));
			}
			mysql = null;
		}
		mysqlSqlGen = null;
	}
	
	void execute(char[] sql)
	{
		int error = mysql_real_query(mysql, sql.ptr, sql.length);
		if (error) {
		        Cout("execute(): ");
		        Cout(toDString(mysql_error(mysql)));
		        Cout("\n").flush;			
		        throw new DBIException("Unable to execute a command on the MySQL database.", sql, error, specificToGeneral(error));
		}
	}
	
	void execute(char[] sql, BindType[] paramTypes, void*[] ptrs)
	{
		auto execSql = new DisposableStringWriter(sql.length * 2);
		virtualBind(sql, paramTypes, ptrs, this.getSqlGenerator, execSql);
		execute(execSql.get);
		execSql.free;
		delete execSql;
	}
        
    IStatement prepare(char[] sql)
	{
		MYSQL_STMT* stmt = mysql_stmt_init(mysql);
		auto res = mysql_stmt_prepare(stmt, sql.ptr, sql.length);
		if(res != 0) {
			debug(Log) {
				auto err = mysql_stmt_error(stmt);
				log.error("Unable to create prepared statement: \"" ~ sql ~"\", errmsg: " ~ toDString(err));
			}
			//return null;
			auto errno = mysql_stmt_errno(stmt);
			throw new DBIException("Unable to prepare statement: " ~ sql, errno, specificToGeneral(errno));
		}
		return new MysqlPreparedStatement(stmt);
	}
			
	IStatement virtualPrepare(char[] sql)
    {
    	return new MysqlVirtualStatement(sql, getSqlGenerator, mysql);
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
	
	char[] escape(char[] str)
	{
		assert(false, "Not implemented");
		//char* res = new char[str.length];
		char* res;
		mysql_real_escape_string(mysql, res, str.ptr, str.length);
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
               
    override SqlGenerator getSqlGenerator()
	{
    	if(mysqlSqlGen is null)
    		mysqlSqlGen = new MysqlSqlGenerator(mysql);
		return mysqlSqlGen;
	}

	package:
		MYSQL* mysql;
	
	private:
    	MysqlSqlGenerator mysqlSqlGen;
}

class MysqlSqlGenerator : SqlGenerator
{
	this(MYSQL* mysql)
	{
		this.mysql = mysql;
	}
	
	private MYSQL* mysql;
	
	override char getIdentifierQuoteCharacter()
	{
		return '`'; 
	}
}

private class MysqlRegister : Registerable {
	
	public char[] getPrefix() {
		return "mysql";
	}
	
	/**
	 * Supports urls of the form mysql://[hostname][:port]/[dbname][?param1][=value1][&param2][=value2]...
	 * 
	 * Note: Does not support failoverhost's as in the MySQL JDBC spec.  Not all parameters
	 * are supported - see the connect method for supported parameters.
	 *
	 */
	public Database getInstance(char[] url) {
		char[] host = "127.0.0.1";
		char[] port, dbname, params;

		auto fields = delimit(url, "/");
		
		if(fields.length) {
			auto fields1 = delimit(fields[0], ":");
			
			if(fields1.length) {
				if(fields1[0].length) host = fields1[0];
				if(fields1.length > 1 && fields1[1].length) port = fields1[1];
			}
			
			if(fields.length > 1) {
				auto fields2 = delimit(fields[1], "?");
				if(fields2.length) { 
					dbname = fields2[0];
					if(fields2.length > 1) params = fields2[1];
				}
			}
		}
		return new MysqlDatabase(host, port, dbname, params);
	}
}

static this() {
	Cout("Attempting to register MysqlDatabase in Registry").newline;
	registerDatabase(new MysqlRegister());
}

debug(UnitTest) {
unittest {

    void s1 (char[] s) {
        tango.io.Stdout.Stdout(s).newline();
    }

    void s2 (char[] s) {
        tango.io.Stdout.Stdout("   ..." ~ s).newline();
    }

	s1("dbi.mysql.MysqlDatabase:");
	MysqlDatabase db = new MysqlDatabase();
/+	s2("connect");
	db.connect("dbname=test", "test", "test");

	s2("query");
	Result res = db.query("SELECT * FROM test");
	assert (res !is null);

	s2("fetchRow");
	Row row = res.fetchRow();
	assert (row !is null);
	assert (row.getFieldIndex("id") == 0);
	assert (row.getFieldIndex("name") == 1);
	assert (row.getFieldIndex("dateofbirth") == 2);
	assert (row.get("id") == "1");
	assert (row.get("name") == "John Doe");
	assert (row.get("dateofbirth") == "1970-01-01");
	/** Todo: MySQL type retrieval is not functioning */
	//assert (row.getFieldType(1) == FIELD_TYPE_STRING);
	//assert (row.getFieldDecl(1) == "char(40)");
	res.finish();

	s2("prepare");
	Statement stmt = db.prepare("SELECT * FROM test WHERE id = ?");
	stmt.bind(1, "1");
	res = stmt.query();
	row = res.fetchRow();
	res.finish();
	assert (row[0] == "1");

	s2("fetchOne");
	row = db.queryFetchOne("SELECT * FROM test");
	assert (row[0] == "1");

	s2("execute(INSERT)");
	db.execute("INSERT INTO test VALUES (2, 'Jane Doe', '2000-12-31')");

	s2("execute(DELETE via prepare statement)");
	stmt = db.prepare("DELETE FROM test WHERE id=?");
	stmt.bind(1, "2");
	stmt.execute();

	s2("close");
	db.close();+/
    auto sqlgen = db.getSqlGenerator;
    auto res = sqlgen.makeInsertSql("user", ["name", "date"]);
	assert(res == "INSERT INTO `user` (`name`,`date`) VALUES(?,?)", res);
}

}

debug(UnitTest) {
	
	import tango.util.log.ConsoleAppender;
	import tango.util.log.Log;
	import tango.time.Clock;
	
	import dbi.util.DateTime;
	import dbi.ErrorCode;

	class MysqlTest : DBTest
	{
		this(Database db, bool virtual = false)
		{
			super(db, virtual);
		}
		
		void setup()
		{
			char[] drop_test = "DROP TABLE IF EXISTS `test`.`test`;";
			
			Stdout.formatln("executing: {}", drop_test);
			
			db.execute(drop_test);
			
			char[] create_test = "CREATE TABLE  `test`.`test` ( "
				"`id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, "
				"`name` varchar(45) NOT NULL, "
				"`binary` tinyblob NULL, "
				"`dateofbirth` datetime default NULL, "
				"PRIMARY KEY  (`id`) "
			") DEFAULT CHARSET=utf8; ";
			
			Stdout.formatln("executing: {}", create_test);
			
			db.execute(create_test);
		}
		
		void teardown()
		{
			
		}
	}
	
	unittest
	{
		try
		{
			Log.getRootLogger.addAppender(new ConsoleAppender);
			
			auto db = new MysqlDatabase("localhost", null, "test", "username=test&password=test");
			//auto db = getDatabaseForURL("mysql://localhost/test?username=test&password=test");
			
			auto test = new MysqlTest(db);
			test.run;
			
			auto testVirtual = new MysqlTest(db);
			testVirtual.run;
			
			assert(db.hasTable("test"));
			TableInfo ti;
			assert(db.getTableInfo("test", ti));
			assert(ti.fieldNames.length == 4);
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
		catch(DBIException ex)
		{
			Stdout.formatln("Caught DBIException: {}, DBI Code:{}, DB Code:{}, Sql: {}", ex.toString, toString(ex.getErrorCode), ex.getSpecificCode, ex.getSql);
			throw ex;
		}
	}
}

}