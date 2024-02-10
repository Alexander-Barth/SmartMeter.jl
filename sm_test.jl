using Pkg

#Pkg.activate(expanduser("~/src/SmartMeter.jl/test-env"))

using Dates
using LibSerialPort
using SmartMeter
using SQLite


#sp = open("/home/abarth/p1.log","r")


portname = "/dev/ttyUSB0"
baudrate = 115200

sp = LibSerialPort.open(portname,baudrate, mode=SP_MODE_READ, parity=SP_PARITY_NONE)


dbfile = expanduser("~/SmartMeter.sqlite")
#rm(dbfile)
db = SQLite.DB(dbfile)


SmartMeter.create_table(db)


for record in SmartMeter.RecordIterator(sp)

    @show  record[:time]

    SmartMeter.insert_record(db,record)

    #    push!(records,record)

    #for line in split(lines)
    #printc("power consumption ",power_consumption,power_consumption_max)
    #println("""{"consumption": $power_consumption, "injection": $power_injection}""")
end


#=
rr = list_records(db)
#r = first(rr)

for r in SmartMeter.list_records(db)
    @show r.time,r.power_consumption
end
=#

DBInterface.close!(db)


