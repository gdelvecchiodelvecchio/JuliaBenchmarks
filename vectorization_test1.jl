#time test  vectorization vs explicit cycles

using PyPlot

function tvectorized(g::Function, x::Array)
    return @elapsed g.(x)
end

function tcycles_fast(g::Function, x::Array)
    ris = Array{Any}(length(x))
    time = @elapsed (
                        @inbounds @fastmath for i in 1:length(x)
                            ris[i] = g(x[i])
                        end
                    )
    return time
end

function tcycles(g::Function, x::Array)
    ris = Array{Any}(length(x))
    time = @elapsed (
                        for i in 1:length(x)
                            ris[i] = g(x[i])
                        end
                    )
    return time
end


dim = 10^4
rep = 100

time_vec = Array{Float64}(dim)
time_cyc = Array{Float64}(dim)
time_cyc_fast = Array{Float64}(dim)

mtv = Array{Float64}(rep)
mtc = Array{Float64}(rep)
mtc_fast = Array{Float64}(rep)

y = collect(0.:0.01:2.*pi)

for j in 1:rep
    for i in 1:dim
        time_vec[i] = tvectorized(exp, y)
        time_cyc[i] = tcycles(exp, y)
        time_cyc_fast[i] = tcycles_fast(exp, y)
    end
    mtv[j] = mean(time_vec)
    mtc[j] = mean(time_cyc)
    mtc_fast[j] = mean(time_cyc_fast)
end

x = collect(1:rep)

f1 = plt[:figure](1)
plt[:plot](x, mtv, color = "r", label = "Vectorized")
plt[:plot](x, mtc, color = "b", label = "Cycled")
plt[:plot](x, mtc_fast, color = "g", label = "Fastly Cycled")
plt[:title]("Time Vectorization vs Cycling")
plt[:legend](loc = "upper right")
plt[:show]()
println("Vectorized/Cycled =  $(mean(mtv ./ mtc))")
println("Cycled/Fastly Cycled = $(mean(mtc ./ mtc_fast))")
