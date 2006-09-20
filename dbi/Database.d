/**
 * Authors: The D DBI project
 *
 * Version: 0.2.4
 *
 * Copyright: BSD license
 */
module dbi.Database;

version (Ares) {
	private static import std.regexp;
	debug (UnitTest) private import std.io.Console;
} else {
	private static import std.string;
	debug (UnitTest) private import std.stdio;
}
private import dbi.DBIException, dbi.Result, dbi.Row, dbi.Statement;

/**
 * The database interface that all DBDs must inherit from.
 *
 * Database only provides a core set of functionality.  Many DBDs have functions
 * that are specific to themselves, as they wouldn't make sense in any many other
 * databases.  Please reference the documentation for the DBD you will be using to
 * discover these functions.
 *
 * See_Also:
 *	The database class for the DBD you are using.
 */
abstract class Database {
	/**
	 * Connect to a database.
	 *
	 * Note that each DBD treats the parameters a slightly different way, so
	 * this is currently the only core function that cannot have its code
	 * reused for another DBD.
	 *
	 * Params:
	 *	params = A string describing the connection parameters.
	 *             documentation for the DBD before
	 *	username = The _username to _connect with.  Some DBDs ignore this.
	 *	password = The _password to _connect with.  Some DBDs ignore this.
	 */
	abstract void connect (char[] params, char[] username = null, char[] password = null);

	/**
	 * A destructor that attempts to force the the release of of all
	 * database connections and similar things.
	 *
	 * The current D garbage collector doesn't always call destructors,
	 * so it is HIGHLY recommended that you close connections manually.
	 */
	~this () {
		close();
	}

	/**
	 * Close the current connection to the database.
	 */
	abstract void close ();

	/**
	 * Prepare a SQL statement for execution.
	 *
	 * Params:
	 *	sql = The SQL statement to execute.
	 *
	 * Returns:
	 *	The prepared statement.
	 */
	final Statement prepare (char[] sql) {
		return new Statement(cast(Database)this, sql);
	}

	/**
	 * Execute a SQL statement that returns no results.
	 *
	 * Params:
	 *	sql = The SQL statement to _execute.
	 */
	abstract void execute (char[] sql);

	/**
	 * Query the database.
	 *
	 * Params:
	 *	sql = The SQL statement to execute.
	 *
	 * Returns:
	 *	A Result object with the queried information.
	 */
	abstract Result query (char[] sql);

	/**
	 * Query the database and return only the first row.
	 *
	 * Params:
	 *	sql = The SQL statement to execute.
	 *
	 * Returns:
	 *	A Row object with the queried information or null for an empty set.
	 */
	final Row queryFetchOne (char[] sql) {
		Result res = query(sql);
		Row row = res.fetchRow();
		res.finish();
		return row;
	}

	/**
	 * Query the database and return an array of all the rows.
	 *
	 * Params:
	 *	sql = The SQL statement to execute
	 *
	 * Returns:
	 *	An array of Row objects with the queried information.
	 */
	final Row[] queryFetchAll (char[] sql) {
		Result res = query(sql);
		Row[] rows = res.fetchAll();
		res.finish();
		return rows;
	}

	/**
	 * Get the error code.
	 *
	 * Deprecated:
	 *	This functionality now exists in DBIException.  This will be
	 *	removed in version 0.3.0.
	 *
	 * Returns:
	 *	The database specific error code.
	 */
	deprecated abstract int getErrorCode ();

	/**
	 * Get the error message.
	 *
	 * Deprecated:
	 *	This functionality now exists in DBIException.  This will be
	 *	removed in version 0.3.0.
	 *
	 * Returns:
	 *	The database specific error message.
	 */
	deprecated abstract char[] getErrorMessage ();

	/**
	 * Split a _string into keywords and values.
	 *
	 * Params:
	 *	string = A _string in the form keyword1=value1;keyword2=value2;etc.
	 *
	 * Returns:
	 *	An associative array containing keywords and their values.
	 *
	 * Throws:
	 *	DBIException if string is malformed.
	 */
	final protected char[][char[]] getKeywords (char[] string) {
		char[][char[]] keywords;
		version (Ares) {
			foreach (char[] group; std.regexp.split(string, ";")) {
				if (group == "") {
					continue;
				}
				char[][] vals = std.regexp.split(group, "=");
				keywords[vals[0]] = vals[1];
			}
		} else {
			foreach (char[] group; std.string.split(string, ";")) {
				if (group == "") {
					continue;
				}
				char[][] vals = std.string.split(group, "=");
				keywords[vals[0]] = vals[1];
			}
		}
		return keywords;
	}
}

private class TestDatabase : Database {
	void connect (char[] params, char[] username = null, char[] password = null) {}
	void close () {}
	void execute (char[] sql) {}
	Result query (char[] sql) {return null;}
	deprecated int getErrorCode () {return 0;}
	deprecated char[] getErrorMessage () {return "";}

}

unittest {
	version (Ares) {
		void s1 (char[] s) {
			Cout("" ~ s ~ "\n");
		}

		void s2 (char[] s) {
			Cout("   ..." ~ s ~ "\n");
		}
	} else {
		void s1 (char[] s) {
			writefln("%s", s);
		}

		void s2 (char[] s) {
			writefln("   ...%s", s);
		}
	}


	s1("dbi.Database:");
	TestDatabase db;

	s2("getKeywords");
	char[][char[]] keywords = db.getKeywords("dbname=hi;host=local;");
	assert(keywords["dbname"] == "hi");
	assert(keywords["host"] == "local");
}