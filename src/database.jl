
dbtype(::DateTime) = "DATETIME NOT NULL"
dbtype(::Float64) = "REAL NOT NULL"
dbtype(::Integer) = "INTEGER NOT NULL"




function create_table(db)
    cols = join([string(varname," ",dbtype(initval)) for  (okey,varname,initval) in fields],",\n")

    DBInterface.execute(db, """CREATE TABLE IF NOT EXISTS smartmeter ($cols)""")
end

function insert_record(db,record)
    columns = getindex.(fields,2)
    placeholder = join(fill("?",length(columns)),',')

    DBInterface.execute(
        db,
        "INSERT INTO smartmeter VALUES ($placeholder)",
        [record[c] for c in columns]
    )
end

function list_records(db)
    rr = DBInterface.execute(
    db,
    "SELECT * FROM smartmeter"
    );
    return rr
end
