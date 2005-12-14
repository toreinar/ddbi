NATDOCS=/usr/bin/NaturalDocs

PKGNAME=ddbi
PKGVER=0.1.5
PKGDIR=$(PKGNAME)-$(PKGVER)

DMDFLAGS=-w
DEBUG=
UNITTEST=

SQLITE_LIB=libddbi_sqlite3.a
SQLITE_SRCS=dbi/sqlite/imp.d dbi/sqlite/SqliteDatabase.d dbi/sqlite/SqliteResult.d

PG_LIB=libddbi_pg.a
PG_SRCS=dbi/pg/imp.d dbi/pg/PgDatabase.d dbi/pg/PgResult.d

MYSQL_LIB=libddbi_mysql.a
MYSQL_SRCS=dbi/mysql/imp.d dbi/mysql/MysqlDatabase.d dbi/mysql/MysqlResult.d

all: $(SQLITE_LIB) $(MYSQL_LIB)

$(SQLITE_LIB): $(SQLITE_SRCS) $(DBI_SRCS)
	build $(DMDFLAGS) $(UNITTEST) $(DEBUG) \
	      -T$(SQLITE_LIB) -full -allobj -lib dbi/sqlite/all.d

$(PG_LIB): objdir $(PG_SRCS) $(DBI_SRCS) ni_error
	build $(DMDFLAGS) $(UNITTEST) $(DEBUG) \
	      -T$(PG_LIB) -full -allobj -lib dbi/pg/all.d

$(MYSQL_LIB): $(MYSQL_SRCS) $(DBI_SRCS)
	build $(DMDFLAGS) $(UNITTEST) $(DEBUG) \
	      -T$(MYSQL_LIB) -full -allobj -lib dbi/mysql/all.d

unittest_sqlite: createdb_sqlite
	@echo "import dbi.sqlite.SqliteDatabase;" > unittest_sqlite.d
	@echo "int main(char[][] args) {return 0;}" >> unittest_sqlite.d
	build $(DMDFLAGS) $(DEBUG) unittest_sqlite.d -unittest -L-lsqlite3
	@rm -f unittest_sqlite.*

unittest_mysql: createdb_mysql
	@echo "import dbi.mysql.MysqlDatabase;" > unittest_mysql.d
	@echo "int main(char[][] args) {return 0;}" >> unittest_mysql.d
	build $(DMDFLAGS) unittest_mysql.d -unittest -L-lmysqlclient -g
	@rm -f unittest_mysql.*

unittest_pg: createdb_pg
	@echo "import dbi.pg.PgDatabase;" > unittest_pg.d
	@echo "int main(char[][] args) {return 0;}" >> unittest_pg.d
	build $(DMDFLAGS) unittest_pg.d -unittest -L-lpq -g
	@rm -f unittest_pg.*

createdb_sqlite:
	@rm -f _test.db
	sqlite3 _test.db < _test_sqlite.sql

createdb_mysql:
	mysql -u test --password=test test < _test_mysql.sql

createdb_pg:
	psql test < _test_pg.sql

docs:
	mkdir -p docs/html
	@echo "Building API documents"
	@mt log > log.txt
	@../mtlogcvt/mtlogcvt -d "%m/%d/%Y %T" -m -t ./docs/default.tpl log.txt - > docs/html/ChangeLog.html
	@cp ../mtlogcvt/default.css ./docs/html/default.css
	@$(NATDOCS) -r -s jeremy -i dbi -i docs -o FramedHTML docs/html -p .nd 

dist:
	make unittest_sqlite unittest_mysql unittest_pg
	./unittest_sqlite
	./unittest_mysql
	./unittest_pg
	make clean docs
	mkdir -p $(PKGDIR)
	cp -a Makefile dbi docs .nd $(PKGDIR)
	rm -rf $(PKGDIR)/.nd/Data
	tar -cvzf $(PKGDIR).tar.gz $(PKGDIR)
	rm -rf $(PKGDIR)
	@./update-site.sh $(PKGDIR).tar.gz

clean:
	rm -rf _test.db unittest_* docs/html/* $(PKGDIR) $(PKGDIR).tar.gz
	rm -rf dbi/*.o dbi/mysql/*.o dbi/sqlite/*.o
	rm -rf $(MYSQL_LIB) $(SQLITE_LIB) $(PG_LIB)

.PHONY: createdb_sqlite createdb_mysql createdb_pg docs clean dist
