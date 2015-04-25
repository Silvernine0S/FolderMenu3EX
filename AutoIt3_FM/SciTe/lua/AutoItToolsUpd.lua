--------------------------------------------------------------------------------
-- CreateFunctionHeader(s, p)
--
-- Creates a function header for an AutoIt 3 function.
--
-- Parameters:
--  s - The name of a function.
--  p - The parameters to the function.
--
-- Returns:
--  A string containing the function header.
--------------------------------------------------------------------------------
function AutoItTools:CreateFunctionHeader(s, p)
    -- Change these :)
    local defAuthor = props['UDFCreator']    -- Initial Author value

    local defLineMax = 129                   -- Max length of line. AutoIt standard is 129.
    local defSplit = 21                      -- Default index for '-' after param.

    local nl = self:NewLineInUse()

    local outStart   = "FUNCTION"
    local outName    = s
    local outDesc    = ""
    local outSyntax  = ""
    local outParams  = ""
    local outReturn  = "None"
    local outAuthor  = defAuthor
    local outModify  = ""
    local outRemarks = ""
    local outRelated = ""
    local outLink    = ""
    local outExample = "No"

    local name = s
    local params = p

    if name:sub(0, 2) == "__" then
        outStart = "INTERNAL_USE_ONLY"
    end

    outSyntax = name .. "("

    local paramSynt = ""
    local iOptionals = 0
    local fBroken = false
    local sModifiers = ""
    if params ~= "" and params ~= nil then
        for byref, parameter, optional in string.gfind(params, "(%w-%s*%w*)%s*($[%w_]+)%s*[=]?%s*(.-)[,%)]") do
            if parameter ~= "" and parameter ~= nil then
                if outParams ~= "" then
                    outParams = outParams .. nl .. ";" .. string.rep(" ", 18)
                end

                outParams = outParams .. parameter .. string.rep(" ", defSplit - string.len(parameter)) .. "- "

                sModifiers = ""
                if optional ~= "" and optional ~= nil then
                    outParams = outParams .. "[optional] "

                    if paramSynt ~= "" then
                        paramSynt = paramSynt .. "[, "
                    else
                        paramSynt = paramSynt .. "["
                    end

                    iOptionals = iOptionals + 1
                else
                    byref = string.gsub(byref:lower(), "%s", "")
                    if byref ~= "" then
                        if byref == "byref" then
                            outParams = outParams .. "[in/out] "
                            sModifiers = "Byref "
                        else
                            if byref == "const" then
                                outParams = outParams .. "[const] "
                                sModifiers = "Const "
                            else
                                if byref == "byrefconst" or byref == "constbyref" then
                                    outParams = outParams .. "[in/out and const] "
                                    sModifiers = "Const Byref "
                                else
                                    print("Unrecognised parameter modifiers: '" .. byref .. "'")
                                end
                            end
                        end
                    end

                    if paramSynt ~= "" then
                        paramSynt = paramSynt .. ", "
                    end
                end

                if fBroken then
                    if string.len(paramSynt) + string.len(parameter) + iOptionals + 2 + 19 > defLineMax then
                        outSyntax = outSyntax .. paramSynt .. nl .. ";" .. string.rep(" ", 18)
                        paramSynt = ""
                        fBroken = true
                    end
                else
                    if string.len(outSyntax) + string.len(paramSynt) + string.len(parameter) + iOptionals + 2 + 19 > defLineMax then
                        outSyntax = outSyntax .. paramSynt .. nl .. ";" .. string.rep(" ", 18)
                        paramSynt = ""
                        fBroken = true
                    end
                end
                paramSynt = paramSynt .. sModifiers .. parameter

                if optional ~= "" and optional ~= nil then
                    paramSynt = paramSynt .. " = " .. optional
                end

                local paramtype = parameter:sub(2, 2)
                local isarray = false
                if paramtype == "a" then
                    paramtype = parameter:sub(3, 3)
                    isarray = true
                end

                local sAdd
                if paramtype == "i" then
                    sAdd = "integer"
                elseif paramtype == "f" then
                    sAdd = "boolean"
                elseif paramtype == "b" then
                    sAdd = "binary"
                elseif paramtype == "n" then
                    sAdd = "floating point number"
                elseif paramtype == "s" then
                    sAdd = "string"
                elseif paramtype == "h" then
                    sAdd = "handle"
                elseif paramtype == "v" then
                    sAdd = "variant"
                elseif paramtype == "p" then
                    sAdd = "pointer"
                elseif paramtype == "t" then
                    sAdd = "dll struct"
                else
                    sAdd = "unknown"
                end

                if isarray then
                    outParams = outParams .. "An array of " .. sAdd .. "s."
                else
                    if sAdd:sub(1, 1):find("[AEIOUaeiou]") ~= nil then
                        outParams = outParams .. "An " .. sAdd .. " value."
                    else
                        outParams = outParams .. "A " .. sAdd .. " value."
                    end
                end

                if optional ~= "" and optional ~= nil then
                    outParams = outParams .. " Default is " .. optional .. "."
                end
            end
        end
    else
        outParams = "None"
    end

    outSyntax = outSyntax .. paramSynt .. string.rep("]", iOptionals) .. ")"

    local res = "; #" .. outStart .. "# " .. string.rep("=", defLineMax - 5 - outStart:len()) .. nl
    res = res .. "; Name ..........: " .. outName .. nl
    res = res .. "; Description ...: " .. outDesc .. nl
    res = res .. "; Syntax ........: " .. outSyntax .. nl
    res = res .. "; Parameters ....: " .. outParams .. nl
    res = res .. "; Return values .: " .. outReturn .. nl
    res = res .. "; Author ........: " .. outAuthor .. nl
    res = res .. "; Modified ......: " .. outModify .. nl
    res = res .. "; Remarks .......: " .. outRemarks .. nl
    res = res .. "; Related .......: " .. outRelated .. nl
    res = res .. "; Link ..........: " .. outLink .. nl
    res = res .. "; Example .......: " .. outExample .. nl
    res = res .. "; " .. string.rep("=", defLineMax - 2) .. nl

    return res
end -- CreateFunctionHeader()

--------------------------------------------------------------------------------
-- CreateStructureHeader(s, p)
--
-- Creates a structure header for an AutoIt 3 struct.
--
-- Parameters:
--  s - The name of a structure.
--  p - The complete structure definition.
--
-- Returns:
--  A string containing the structure header.
--------------------------------------------------------------------------------
function AutoItTools:CreateStructureHeader(s, p)
    local defAuthor = props['UDFCreator']    -- Initial Author value

    local defLineMax = 129                   -- Max length of line. AutoIt standard is 129.
    local defSplit = 21                      -- Default index for '-' after param.

    local nl = self:NewLineInUse()

    local outStart   = "STRUCTURE"
    local outName    = s
    local outDesc    = ""
    local outFields  = ""
    local outAuthor  = defAuthor
    local outRemarks = ""
    local outRelated = ""

    local str
    if p ~= "" and p ~= nil then
        p = p:sub(p:find("[\"']"), -1)

        for sect in string.gfind(p, "%s*(.-)%s*[;\"']") do

            if sect:match("[Aa][Ll][Ii][Gg][Nn]%s+%d+") then
                -- Align statement: Ignore
            else
                str = sect:match("^%s*&%s*$([%w_]+)%s&%s*$")
                if str ~= nil then
                    -- Substruct

                    if outFields ~= "" then
                        outFields = outFields .. nl .. ";" .. string.rep(" ", 18)
                    end

                    outFields = outFields .. str .. string.rep(" ", defSplit - string.len(str)) .. "- A $" .. str .. " structure."
                else
                    if sect == nil or sect == "" or sect:upper() == "STRUCT" or sect:upper() == "ENDSTRUCT" then
                        -- Substruct or empty: Ignore
                    else
                        local datatype, name = sect:match("^(.-)%s+(.-)$")

                        if outFields ~= "" then
                            outFields = outFields .. nl .. ";" .. string.rep(" ", 18)
                        end

                        outFields = outFields .. name .. string.rep(" ", defSplit - string.len(name)) .. "- "

                        if datatype:sub(1, 1):find("[AEIOUaeiou]") ~= nil then
                            outFields = outFields .. "An "
                        else
                            outFields = outFields .. "A "
                        end

                        outFields = outFields .. datatype .. " value."
                    end
                end
            end

        end
    end

    local res = "; #" .. outStart .. "# " .. string.rep("=", defLineMax - 5 - outStart:len()) .. nl
    res = res .. "; Name ..........: " .. outName .. nl
    res = res .. "; Description ...: " .. outDesc .. nl
    res = res .. "; Fields ........: " .. outFields .. nl
    res = res .. "; Author ........: " .. outAuthor .. nl
    res = res .. "; Remarks .......: " .. outRemarks .. nl
    res = res .. "; Related .......: " .. outRelated .. nl
    res = res .. "; " .. string.rep("=", defLineMax - 2) .. nl

    return res
end -- CreateStructureHeader

--------------------------------------------------------------------------------
-- InsertFunctionHeader()
--
-- Generates a function header and inserts it into the document.
--
-- Tool: AutoItTools.InsertFunctionHeader $(au3) savebefore:no,groupundo:yes Alt+U Insert Function Header
--------------------------------------------------------------------------------
function AutoItTools:InsertFunctionHeader()
    local line, pos = editor:GetCurLine()
    local pos = editor.CurrentPos - pos
    local lineNum = editor:LineFromPosition(pos)
    local from, to, name = line:find("[Ff][Uu][Nn][Cc][%s]*([%w%s_]*)")
    local struct = false

    if to == nil then
        from, to, name = line:find("[Gg][Ll][Oo][Bb][Aa][Ll]%s+[Cc][Oo][Nn][Ss][Tt]%s+($[%w_]+)")
        struct = true
        if to == nil then
            print("Function or struct definition not found, unable to insert header.")
            return
        end
    end

    -- remove comments from the line
    from, to =  line:find(";")
    while from ~= nil do
        -- print(pos+from .. " type:" .. editor.StyleAt[pos+from])
        if editor.StyleAt[pos+from] == SCE_AU3_COMMENT then
            line = string.sub (line, 1 , from-1)   -- remove comment
            from = nil                             -- exit loop
        else
            from, to =  line:find(";",from+1)      -- find next ; as this one is not a comment
        end
    end
    -- print(" line:" .. line)
    local pfrom, pto = line:find("%(")    -- check for opening parenthesis
    if struct then
        pfrom, pto = line:find("[\"']")
    end

    if pto ~= nil then
        local i = 0
        local tmp
        while line:find("%s+_%s*$") do    -- found a line continuation
            line = line:gsub("%s+_%s*$", "")    -- remove it
            i = i + 1
            pos = editor:PositionFromLine(lineNum+i)    -- set new position
            tmp = editor:GetLine(lineNum+i)
            -- remove comments from the line
            from, to =  tmp:find(";")
            while from ~= nil do
                -- print(pos+from .. " type:" .. editor.StyleAt[pos+from])
                if editor.StyleAt[pos+from] == SCE_AU3_COMMENT then
                    tmp = string.sub (tmp, 1 , from-1)   -- remove comment
                    from = nil                             -- exit loop
                else
                    from, to =  tmp:find(";",from+1)      -- find next ; as this one is not a comment
                end
            end
            tmp = tmp:gsub("^%s*", "")    -- remove leading white space
            line = line .. tmp
        end
        editor:Home()
        line = line:gsub("[\r\n]", "")    -- remove line breaks
        line = line:gsub("[\"']%s*&%s*[\"']", "") -- remove string joins

        if name:sub(1, 1) == "$" then
            editor:AddText(self:CreateStructureHeader(name, line))
        else
            editor:AddText(self:CreateFunctionHeader(name, line))
        end
    else
        print("Argument list not found, unable to insert header.")
	end
end -- InsertFunctionHeader()
