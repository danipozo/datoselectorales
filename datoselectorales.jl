using Gadfly

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

n = ["Partido 1","Partido 2","Partido 3","Partido 4","Partido 5",]
v = [340000.0, 280000.0, 160000.0, 60000.0, 15000.0]
e = DHont(7, 5, v, sum(v))

println(e)

draw(SVG("plot.svg", 7inch, 7inch), plot(x=n, y=e, Geom.bar, Theme(bar_spacing=0.2inch), color=n, Scale.color_discrete_manual(colorant"rgb(255,0,0)", colorant"rgb(0,255,0)", colorant"rgb(0,0,255)")))
