using DataFrames, Gadfly

# DHont method. Takes filtered data.
function DHont(ne::Int64, np::Int64, vp::Array{Float64,1}, vt::Float64)
    a = [vp[i] for i=1:np]
    #filter!(v->v/vt >= 0.03, a)
    (s,) = size(a)
    e = [0 for i=1:s]

    for i=1:ne
        (x,j) = findmax(a)
        e[j] = e[j] + 1
        a[j] = vp[j]/(e[j]+1)     
    end

    return e
end

function GetRegionData2015(region)
    rFile = "CSV2015/"*region*".csv"
    t = readtable(rFile, header=false)

    (f,c) = size(t)
    ne = parse(Int64, t[f,1])
    np = div(c-8,2)
    vp = [parse(Float64, t[f-1,i]) for i=9:2:(c-1)]
    vt = parse(Float64, t[f-1,5])

    cand = [t[1,i] for i=9:2:(c-1)]
    e_real = [parse(Int64, t[f-1,i]) for i=10:2:c]

    cand_vp = [[vp[i], cand[i], e_real[i]] for i=1:np]

    filter!(v->v[1]/vt >= 0.03 || v[3]!=0, cand_vp)
    (s,) = size(cand_vp)

    cand = [cand_vp[i][2] for i=1:s]
    vp = [Float64(cand_vp[i][1]) for i=1:s]
    e_real = [cand_vp[i][3] for i=1:s]


    e = DHont(ne, s, vp, vt)

    aux = [[cand[i], e[i], e_real[i]] for i=1:s]
    filter!(v->v[2]!=0 || v[3]!=0, aux)

    (s,) = size(aux)
    cand2 = ["\u89" for i=1:s]
    e2 = [0 for i=1:s]
    e_real2 = [0 for i=1:s]
    for i=1:s
        cand2[i] = aux[i][1]
        e2[i] = aux[i][2]
        e_real2[i] = aux[i][3]
    end

    return cand2, e2, e_real2
end

function GetRegionData2011(region)
    file = "CSV2011/datos.csv"
    t = readtable(file, header=false)
    
    cand = [t[1,i] for i=17:2:139]
    a = [("\u89", 0.0, [], []) for i=3:54]
    s = 0
    for i=1:52
        if(t[i+2,1] == region)
            s += 1
            a[s] = (t[i+2,1], parse(Float64, filter(v->v!=',',t[i+2,13])), [parse(Float64, filter(v->v!=',', t[i+2,j])) for j=17:2:139], [parse(Int64, t[i+2,j]) for j=18:2:140])
        end
    end

    ne = 0
    np = 61
    vp = [0.0 for i=1:61]
    vt = 0.0
    e_real = [0 for i=1:61]

    for i=1:s
        name, _vt, _vp, _e_real = a[i]
        vt += _vt
        for j=1:61
            vp[j] += _vp[j]
            ne += _e_real[j]
            e_real[j] += _e_real[j]
        end
    end

    cand_vp = [[cand[i], vp[i], e_real[i]] for i=1:61]
    filter!(v->v[2]/vt >= 0.03 || v[3]!=0, cand_vp)

    (s,) = size(cand_vp)
    
    cand = [cand_vp[i][1] for i=1:s]
    vp = [Float64(cand_vp[i][2]) for i=1:s]
    e_real = [cand_vp[i][3] for i=1:s]
    
    println(cand, "\n", vp, "\n", e_real)
    
    e = DHont(ne, s, vp, vt)

    aux = [[cand[i], e[i], e_real[i]] for i=1:s]
    filter!(v->v[2]!=0 || v[3]!=0, aux)

    (s,) = size(aux)
    cand2 = ["\u89" for i=1:s]
    e2 = [0 for i=1:s]
    e_real2 = [0 for i=1:s]
    for i=1:s
        cand2[i] = aux[i][1]
        e2[i] = aux[i][2]
        e_real2[i] = aux[i][3]
    end

    return cand2, e2, e_real2
end

function GetStateData2011()
    file = "CSV2011/datos.csv"
    t = readtable(file, header=false)
    
    cand = [t[1,i] for i=17:2:139]

    np = 61
    vp = [parse(Float64, filter(v->v!=',', t[56,i])) for i=17:2:139]
    e_real = [parse(Int64, t[56,i]) for i=18:2:140]
    vt = 0
    ne = 350
    for i=1:61
        vt += vp[i]
    end

    cand_vp = [[vp[i], cand[i], e_real[i]] for i=1:np]
    filter!(v->v[1]/vt >= 0.03 || v[3]!=0, cand_vp)
    (s,) = size(cand_vp)

    cand = [cand_vp[i][2] for i=1:s]
    vp = [Float64(cand_vp[i][1]) for i=1:s]
    e_real = [cand_vp[i][3] for i=1:s]

    e = DHont(ne, s, vp, vt)

    aux = [[cand[i], e[i], e_real[i]] for i=1:s]
    filter!(v->v[2]!=0 || v[3]!=0, aux)

    (s,) = size(aux)
    cand2 = ["\u89" for i=1:s]
    e2 = [0 for i=1:s]
    e_real2 = [0 for i=1:s]
    for i=1:s
        cand2[i] = aux[i][1]
        e2[i] = aux[i][2]
        e_real2[i] = aux[i][3]
    end

    return cand2, e2, e_real2

end

function GetStateData2015()
    file = "CSV2015/Estado.csv"
    t = readtable(file, header=false)

    cand = [t[1,i] for i=1:2:129]
    np = 65
    vp = [parse(Float64, filter(v->v!=',', t[55,i])) for i=1:2:129]
    e_real = [parse(Int64, t[55,i]) for i=2:2:130]
    vt = 0.0
    ne = 350
    for i=1:65
        vt += vp[i]
    end

    cand_vp = [[cand[i], vp[i], e_real[i]] for i=1:65]
    filter!(v->v[2]/vt >= 0.03 || v[3]!=0, cand_vp)

    (s,) = size(cand_vp)
    
    cand = [cand_vp[i][1] for i=1:s]
    vp = [Float64(cand_vp[i][2]) for i=1:s]
    e_real = [cand_vp[i][3] for i=1:s]
    
    println(cand, "\n", vp, "\n", e_real)
    
    e = DHont(ne, s, vp, vt)

    aux = [[cand[i], e[i], e_real[i]] for i=1:s]
    filter!(v->v[2]!=0 || v[3]!=0, aux)

    (s,) = size(aux)
    cand2 = ["\u89" for i=1:s]
    e2 = [0 for i=1:s]
    e_real2 = [0 for i=1:s]
    for i=1:s
        cand2[i] = aux[i][1]
        e2[i] = aux[i][2]
        e_real2[i] = aux[i][3]
    end

    return cand2, e2, e_real2

end

function plotData(title, cand, e_, e_real)
    (s,) = size(cand)
    println(cand, e_, e_real)
    cand2 = [cand[i]*"-"*string(e_[i]) for i=1:s]
    cand3 = [cand[i]*"-"*string(e_real[i]) for i=1:s]

    p1 = plot(x=cand2, y=e_, Geom.bar, Theme(bar_spacing=0.2inch), Guide.ylabel("Escaños asignados"), Guide.xlabel("Candidaturas"), Guide.title("Reparto de escaños simulado"))
    p2 = plot(x=cand3, y=e_real, Geom.bar, Theme(bar_spacing=0.2inch), Guide.ylabel("Escaños asignados"), Guide.xlabel("Candidaturas"), Guide.title("Reparto de escaños real"))


    draw(PDF(title*".pdf", 6inch, 5inch), hstack(p1,p2))

end

if(ARGS[1] == "--comunidad")
    if(ARGS[2] == "2015")
        c, e_, e_real = GetRegionData2015(ARGS[3])
        plotData(ARGS[3], c, e_, e_real)
    else
        c, e_, e_real = GetRegionData2011(ARGS[3])
        plotData(ARGS[3], c, e_, e_real)
    end
else
    if(ARGS[2] == "2011")
        c, e_, e_real = GetStateData2011()
        plotData("Estado2011", c, e_, e_real)
    else
         c, e_, e_real = GetStateData2015()
        plotData("Estado2015", c, e_, e_real)

    end
end
