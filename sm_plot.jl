using GLMakie
using JSON



logpipe = Pipe()

hostname = "192.168.1.61"
username = "pi"
logger = "/home/pi/src/SmartMeter.jl/sm_test.jl"

c = Float64[]
i = Float64[]
nlag = 100

consumption = Observable(zeros(0))
aconsumption = Observable(zeros(0))
ainjection = Observable(zeros(0))

consumption[] = fill(NaN,100)
aconsumption[] = fill(NaN,500)
ainjection[] = fill(NaN,500)


fig = Figure()

ax = Axis(fig[1, 1:2], title = "consumption")
lines!(consumption,linestyle=:solid,linewidth = 5,color = consumption);
xlims!(1,nlag)

ax = Axis(fig[2, 1], title = "aver. consumption")
lines!(aconsumption,linestyle=:solid,linewidth = 5,color = aconsumption);
ylims!(ax,0,5)
xlims!(1,500)

ax = Axis(fig[2, 2], title = "aver. injection")
lines!(ainjection,linestyle=:solid,linewidth = 5,color = ainjection);
ylims!(ax,0,5)
xlims!(1,500)


display(fig)



@info "connecting to $username@$hostname"
pp = run(pipeline(`ssh $username@$hostname julia $logger`,stdout=logpipe),wait=false);

@info "fetching data"



function cappend!(c,v; alpha = 0)
    c[1:end-1] .= c[2:end]

    if isnan(c[end])
        c[end] = v
    else
        c[end] = alpha * c[end] + (1-alpha) * v
    end
    return c
end

alpha = 0.8

line = readline(logpipe);
println(line)

while true;
    line = readline(logpipe);
    println(line)
    j = JSON.parse(line)

    c2 = j["consumption"]
    i2 = j["injection"]

    consumption[] = cappend!(consumption[],c2)
    aconsumption[] = cappend!(aconsumption[],c2,alpha=alpha)
    ainjection[] = cappend!(ainjection[],i2,alpha=alpha)
    display(fig)
end
