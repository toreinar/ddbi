/**
 * Authors: The D DBI project
 * Copyright: BSD license
 */
module dbi.Registry;

private import dbi.Database;

private import tango.text.Util;
private import tango.util.log.Log;

private static Registerable[char[]] dbs;
private static Logger logger;

static this() {
	logger = Log.getLogger("dbi.Registry");
}

/**
 * Interface for registering a database provider.  This will allow you to only 
 * link the database drivers that you will use.
 */
public interface Registerable {
	public char[] getPrefix();
	public Database getInstance(char[] url);
}

/**
 * Used by each database provider to 'register' itself.  This registration is 
 * usually done via a static constructor, so all you need to do is import the 
 * database that you want to use.
 * 
 * Params:
 *     newDB = Registerable instance that will create Database instances when 
 *     asked via getDatabaseForURL.
 */
public static void registerDatabase(Registerable newDB) {
	logger.trace("registering database: " ~ newDB.getPrefix());
	dbs[newDB.getPrefix()] = newDB;
}

/**
 * Given a database URL, instantiate and return a Database instance.
 * 
 * A database URL looks like:
 *   dbprefix://params
 * Where dbprefix is the database provider, such as mysql or oracle.
 * params is currently implementation defined.
 * 
 * Params:
 *     dbUrl = The URL of the database you wish to connect to.
 * Returns: A fully instantiated Database instance.  TODO: Should it call connect()?
 */
public static Database getDatabaseForURL(char[] dbUrl) {
	char[] origURL = dbUrl.dup;
	logger.trace("getDatabaseForURL: " ~ dbUrl);
	char[][] fields = delimit(dbUrl, ":");
	char[] prefix = fields[0];
	return dbs[prefix].getInstance(dbUrl[prefix.length+3 .. $]);
}