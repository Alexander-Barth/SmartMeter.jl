using PyPlot


c = Float64[]


log = Pipe()

hostname = "192.168.1.61"
username = "pi"
logger = "/home/pi/src/SmartMeter.jl/sm_test.jl"

nlag = 100

pp = run(pipeline(`ssh $username@$hostname julia $logger`,stdout=log),wait=false);

while true;
    line = readline(log);
    push!(c,parse(Float64,split(line,":")[2]));
    clf(); plot(
        c[max(end-nlag,1):end]); pause(0.001);
end
