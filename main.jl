using DataFrames, Gadfly

function DHont(ne::Int64, np::Int64, vp::Array{Float64,1}, vt::Float64)
    e = [0 for i=1:np]    
    a = [vp[i] for i=1:np]

    for i=1:ne
        (x,j) = findmax(a)
        e[j] = e[j] + 1
        a[j] = vp[j]/(e[j]+1)     
    end

    return e
end

n1 = readtable("nombres_partidos.csv", header=false, encoding=:utf8)
n = [n1[1,i] for i=1:21]
