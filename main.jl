using DataFrames, Gadfly, Compose

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

function myFilt(v,region)
    x,y = v
    x==region
end

function ProcessRegion(region, year)
    if(year == "2015")
        region = join(["CSV2015/", ""], region)
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

        aux = [[cand[i], e[i]] for i=1:s]
        filter!(v->v[2]!=0, aux)

        (s,) = size(aux)
        cand2 = ["\u89" for i=1:s]
        e2 = [0 for i=1:s]
        for i=1:s
            cand2[i] = aux[i][1]
            e2[i] = aux[i][2]
        end

        return cand2, e2
    else
        rFile = join(["CSV2011/datos", ""], ".csv")
        t = readtable(rFile, header=false)

        a = [[t[i,1], t[i,13]] for i=3:54]
        b = [(t[i,1],[t[i,j] for j=17:2:139], [t[i,j] for j=18:2:140], [t[1,j] for j=17:2:139]) for i=3:54]

        filter!(v->v[1]==region, a)
        filter!(x->myFilt(x,region), b)
        (s,) = size(b)
        c = [[""] for i=1:s]       
        d = [[""] for i=1:s]
        p = [["\u89"] for i=1:s]

        for i=1:s
            x, c[i], d[i], p[i] = b[i]
        end

        for i=1:s
            c[i] = [filter(v->v!=',', c[i][j]) for j=1:61]
        end

        f = [[0.0] for i=1:s]
        g = [[0] for i=1:s]

        for i=1:s
            f[i] = [parse(Float64, c[i][j]) for j=1:61]
            g[i] = [parse(Int64, d[i][j]) for j=1:61]
        end
    
        np = 61
        ne = 0
        vp = [0.0 for i=1:61]
        vt = 0.0
        for i=1:s
            for j=1:61
                ne += g[i][j]
                vp[j] += f[i][j]
                vt += f[i][j]
            end
        end

        cand_vp = [[vp[i], p[1][i]] for i=1:np]
        filter!(v->v[1]/vt >= 0.03, cand_vp)
        (s,) = size(cand_vp)

        cand = [cand_vp[i][2] for i=1:s]

        e = DHont(ne, np, vp, vt)

        aux = [[cand[i], e[i]] for i=1:s]
        filter!(v->v[2]!=0, aux)

        (s,) = size(aux)
        cand2 = ["\u89" for i=1:s]
        e2 = [0 for i=1:s]
        for i=1:s
            cand2[i] = aux[i][1]
            e2[i] = aux[i][2]
        end

        return cand2, e2
               
    end
end

function ProcessState2011()
    rFile = join(["CSV2011/datos", ""], ".csv")
    t = readtable(rFile, header=false)

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
    println(size(cand_vp))

    cand = [cand_vp[i][2] for i=1:s]
    
    e = DHont(ne, np, vp, vt)
    println(size(e))
    
    aux = [[cand[i], e[i], e_real[i]] for i=1:s]
    filter!(v->v[2]!=0 || v->v[3]!=0, aux)

    (s,) = size(aux)
    cand2 = ["\u89" for i=1:s]
    e2 = [0 for i=1:s]
    e2_real = [0 for i=1:s]
    for i=1:s
        cand2[i] = aux[i][1]
        e2[i] = aux[i][2]
        e2_real[i] = aux[i][3]
    end

    return cand2, e2, e2_real
end

if(ARGS[1] == "--comunidad")
    if(ARGS[2] == "2015")
        c,e2 = ProcessRegion(ARGS[3], ARGS[2])
        (s,) = size(e2)

        for i=1:s
            c[i] = join([c[i], ""], join(["-", ""], string(e2[i])))
        end

        draw(PDF(join([ARGS[3], ""], ".pdf"), 4inch, 3inch), plot(x=c, y=e2, Geom.bar, Theme(bar_spacing=0.2inch), Guide.ylabel("Escaños asignados"), Guide.xlabel("Candidaturas")))
    elseif(ARGS[2] == "2011") 
        c,e2 = ProcessRegion(ARGS[3], ARGS[2])
        println(c,e2)
        (s,) = size(e2)

        for i=1:s
            c[i] = join([c[i], ""], join(["-", ""], string(e2[i])))
        end

        draw(PDF(join([ARGS[3], ""], ".pdf"), 5inch, 5inch), plot(x=c, y=e2, Geom.bar, Theme(bar_spacing=0.2inch, minor_label_font_size=10px), Guide.ylabel("Escaños asignados"), Guide.xlabel("Candidaturas")))   
    else
        println("Not a valid year")
    end
else # ARGS[1] == "--estado"
    if(ARGS[2] == "2011")
        c, e2, e2_real = ProcessState2011()
        println(e2)
        (s,) = size(e2)

        c2 = ["\u89" for i=1:s]
        for i=1:s
            c2[i] = join([c[i], ""], join([" - ", ""], string(e2[i])))
        end
        p1 = plot(x=c2, y=e2, Geom.bar, Theme(bar_spacing=0.2inch), Guide.ylabel("Escaños asignados"), Guide.xlabel("Candidaturas"), Guide.title("Reparto de escaños simulado"))
        c3 = ["\u89" for i=1:s]
        for i=1:s
            c3[i] = join([c[i], ""], join([" - ", ""], string(e2_real[i])))
        end
        p2 = plot(x=c3, y=e2_real, Geom.bar, Theme(bar_spacing=0.2inch), Guide.ylabel("Escaños asignados"), Guide.xlabel("Candidaturas"), Guide.title("Reparto de escaños real"))
        draw(PDF(join(["Estado2011", ""], ".pdf"), 6inch, 5inch), hstack(p1,p2))
    else
    end
end

