using Dates
using LibSerialPort
using SQLite

function printc(key,val,max)
    colors =  [:green,
           :light_green,
           :light_blue,
           :light_cyan,
           :light_yellow,
           :light_magenta,
           :magenta,
           :light_red,
           :red,
           :black,
           :bold,
               ]

    i = clamp(round(Int,length(colors) * val / max),1,length(colors))
    print(key,": ")
    printstyled(val,"\n",color=colors[i])
end


#sp = open("/home/abarth/p1.log","r")
portname = "/dev/ttyUSB0"
baudrate = 115200

sp = LibSerialPort.open(portname,baudrate, mode=SP_MODE_READ, parity=SP_PARITY_NONE)

records = []
power_consumption_max = 5.

while true
    if eof(sp)
        break
    end

    line = readline(sp)
    while !isempty(line) && !eof(sp)
        line = readline(sp)
    end

    if eof(sp)
        break
    end

    record = Dict{String,Union{Int,DateTime,Float64}}()
    meter1in = 0.0
    power_consumption = 0.0
    power_injection  = 0.0
    line = readline(sp)

    while !startswith(line,'!') && !startswith(line,'/')
        key,rest = split(line,'(',limit=2)
        val,rest = split(rest,')',limit=2)

        parts = split(val,"*",limit=2)


        value = ""
        units = ""
        if length(parts) == 2
            value,units = parts
        elseif length(parts) == 1
            value, = parts
        end

        if !isempty(value)
            if key in ("0-0:1.0.0",)
                Y,M,D,h,m,sec = parse.(Int,(val[2i-1:2i] for i = 1:6))
                record[key] = DateTime(2000+Y,M,D,h,m,sec)
            elseif key == "1-0:1.8.1"
                meter1in = parse(Float64,value)
            elseif key == "1-0:1.7.0"
                power_consumption = parse(Float64,value)
            elseif key == "1-0:1.7.1"
                power_injection = parse(Float64,value)
            else
                record[key] = parse(Float64,value)
            end
        end
#        @show  record

        line = readline(sp)

    end

    push!(records,record)

    #for line in split(lines)
    printc("power consumption ",power_consumption,power_consumption_max)
end



