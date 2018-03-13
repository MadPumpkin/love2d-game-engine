
-- A sub inheritsFrom() function
--
function subclass( baseClass )

    local sub_class = {}
    local class_mt = { __index = sub_class }

    function sub_class:create()
        local subinst = {}
        setmetatable( subinst, class_mt )
        return subinst
    end

    if nil ~= baseClass then
        setmetatable( sub_class, { __index = baseClass } )
    end

    -- Return the class object of the instance
    function sub_class:class()
        return sub_class
    end

    -- Return the super class object of the instance
    function sub_class:super()
        return baseClass
    end

    -- Return true if the caller is an instance of theClass
    function sub_class:isa( class )
        local b_isa = false

        local cur_class = sub_class

        while ( nil ~= cur_class ) and ( false == b_isa ) do
            if cur_class == class then
                b_isa = true
            else
                cur_class = cur_class:superClass()
            end
        end

        return b_isa
    end

    return sub_class
end
