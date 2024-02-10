function parse_time(val)
    Y,M,D,h,m,sec = parse.(Int,(val[2i-1:2i] for i = 1:6))
    return DateTime(2000+Y,M,D,h,m,sec)
end

parse_float(value) = parse(Float64,value)
parse_int8(value) = parse(Int8,value)

# https://www.cdem.be/13_technical/#what-information-is-provided-with-the-p1-port

# OBIS codes
const fields =
     # key           variable_name       default_value    parsing_function
    [("0-0:1.0.0",   :time,              DateTime(1,1,1), parse_time),
     ("1-0:1.8.1",   :meter1in,          0.,              parse_float),
     ("1-0:1.8.2",   :meter2in,          0.,              parse_float),
     ("1-0:2.8.1",   :meter1out,         0.,              parse_float),
     ("1-0:2.8.2",   :meter2out,         0.,              parse_float),
     ("0-0:96.14.0", :tariff_indicator,  Int8(0),         parse_int8),
     ("1-0:1.7.0",   :power_consumption, 0.,              parse_float),
     ("1-0:2.7.0",   :power_injection,   0.,              parse_float),
     ]



function iterate(ri::RecordIterator,state=nothing)
    sp = ri.sp

    if eof(sp)
        return nothing
    end

    line = readline(sp)
    while !isempty(line) && !eof(sp)
        line = readline(sp)
    end

    if eof(sp)
        return nothing
    end

    record = Dict{Symbol,Union{DateTime,Float64,Int8}}()
    for (key,varname,initval) in fields
        record[varname] = initval
    end

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
            for (okey,varname,initval,parse_function) in fields
                if key == okey
                    record[varname] = parse_function(value)
                end
            end
        end

        line = readline(sp)
    end

    return (record,nothing)
end
