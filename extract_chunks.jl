function main(filename)
    source = open(f -> read(f, String), filename)

    files = Dict{String, Vector{String}}()

    for m in eachmatch(r"```\{[a-zA-Z0-9]+\}(.*?)```"s, source)
        chunk = m.captures[1]
        if occursin(r"#\| filename: ([a-zA-Z0-9\-_.]+)$"m, chunk)
            # we need to write this out
            fnm = match(r"#\| filename: ([a-zA-Z0-9\-_.]+)$"m, chunk).captures[1]
            if occursin("..", fnm) || occursin("/", fnm)
                error("possible directory traversal attack")
            end

            if !haskey(files, fnm)
                files[fnm] = Vector{String}()
            end

            lines = filter(x -> !occursin("#|", x), split(chunk, "\n"))

            push!.(Ref(files[fnm]), lines)
            push!(files[fnm], "") # blank line between chunks
        end
    end

    for (file, content) in pairs(files)
        println(file)
        open(file, "w") do out
            prev = ""
            for str in content
                if str != "" || prev != ""
                    # skip consecutive blank lines
                    write(out, str)
                    write(out, "\n")
                end
                prev = str
            end
        end
    end
end

main(ARGS[1])