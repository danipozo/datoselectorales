using DataFrames, Gadfly

function DHont(ne::Int64, np::Int64, vp::Array{Float64,1}, vt::Float64)
    a = [vp[i] for i=1:np]
    filter!(v->v/vt >= 0.03, a)
    (s,) = size(a)
    e = [0 for i=1:s]

    for i=1:ne
        (x,j) = findmax(a)
        e[j] = e[j] + 1
        a[j] = vp[j]/(e[j]+1)     
    end

    return e
end


function ProcessRegion(region)
    region = join(["CSV/", ""], region)
    rFile = join([region, ""], ".csv")
    t = readtable(rFile, header=false)

    (f,c) = size(t)
    ne = parse(Int64, t[f,1])
    np = div(c-8,2)
    vp = [parse(Float64, t[f-1,i]) for i=9:2:(c-1)]
    vt = parse(Float64, t[f-1,5])

    cand = [t[1,i] for i=9:2:(c-1)]
    
    cand_vp = [[vp[i], cand[i]] for i=1:np]
    
    filter!(v->v[1]/vt >= 0.03, cand_vp)
    (s,) = size(cand_vp)

    cand = [cand_vp[i][2] for i=1:s]

    e = DHont(ne, np, vp, vt)

    return cand, e
end

if(ARGS[1] == "--comunidad")
    c,e = ProcessRegion(ARGS[2])
    draw(PDF(join([ARGS[2], ""], ".pdf"), 4inch, 3inch), plot(x=c, y=e, Geom.bar, Theme(bar_spacing=0.2inch), Guide.ylabel("Escaños asignados"), Guide.xlabel("Candidaturas")))
end

