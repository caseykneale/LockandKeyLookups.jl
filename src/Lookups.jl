struct LockandKeyLookup{ A <: Function, B <: Function, C <: Function, K, T }
    key::K
    tumbler::T
    key_lookup_fn::A
    pin_lookup_fn::B
    emission_fn::C
    key_length::Int
    tumblers::Vector{ Int }
end

Base.length(::LockandKeyLookup) = Base.SizeUnknown()
Base.IteratorSize(::LockandKeyLookup) = Base.SizeUnknown()

"""
    LockandKeyLookup(   key, tumbler,
                        key_lookup_fn, pin_lookup_fn,
                        emitter_fn = ( k, t ) -> key_lookup_fn( k ) == pin_lookup_fn( t ) )

Instantiates a `LockandKeyLookup` iterable object.
The `key` is the iterator to find a matching condition for across the `tumbler` iterators or internally called "pins".

the `_lookup_fn` functions are the functions used to `select` the data from each iteration for matching.
Ie: `key_lookup_fn`     = row -> row[!, [ :id, :time, :address ] ]
    `tumbler_lookup_fn` = row -> row[!, [ :row_id, :t, :Address ] ]

The `emitter_fn` is the function used to determine if there is infact a match, by default it asseses if the lookup functions equate.

"""
function LockandKeyLookup(  key, tumbler,
                            key_lookup_fn, pin_lookup_fn,
                            emitter_fn = ( k, t ) -> k == t)#key_lookup_fn( k ) == pin_lookup_fn( t ) )
    return LockandKeyLookup(    key, tumbler,
                                key_lookup_fn, pin_lookup_fn,
                                emitter_fn,
                                first( size( key ) ), length.(tumbler) )
end

function get_smallest_pin( pin_values, not_nothing )::Int
    is_something    = sum( not_nothing )
    if is_something == 0
        return 0
    elseif is_something == 1
        return findfirst( not_nothing )
    elseif is_something > 1
        return findall( not_nothing )[ argmin( pin_values[ not_nothing ] ) ]
    end
end

unpack_2tuples( x ) = collect.(zip( [ isnothing( i ) ? [ i, i ] : i  for i in x ]... ) )

function Base.iterate( lkl::LockandKeyLookup, state::T = ( iterate( lkl.key ), iterate.(lkl.tumbler) ) ) where T <: Any
    # Get Latest Key:Tumbler State
    ( key_value, key_state ), tumbler_values_and_states = state
    tumbler_values_and_states = collect( tumbler_values_and_states )
    tumbler_values_and_states = convert(Vector{ Union{ eltype(tumbler_values_and_states), Nothing } }, tumbler_values_and_states)
    ( last( key_state ) > lkl.key_length ) && return nothing
    tumbler_values, tumbler_states = unpack_2tuples( tumbler_values_and_states )
    tumbler_values = convert(Vector{ Union{ eltype(tumbler_values), Nothing } }, tumbler_values)
    tumbler_states = convert(Vector{ Union{ eltype(tumbler_states), Nothing } }, tumbler_states)
    # Get Lowest Pin
    get_key               = lkl.key_lookup_fn( key_value )
    tumbler_values        = collect(tumbler_values)
    notnothing            = .!isnothing.( tumbler_values )
    get_pins              = map( x -> isnothing(x) ? x : lkl.pin_lookup_fn( x ), tumbler_values )
    smallest_pin          = get_smallest_pin( get_pins, notnothing )
    (smallest_pin == 0) && return nothing
    #pre-allocate output
    key_idx, tumbler_idx, pin_idx  = last(key_state), smallest_pin, last( tumbler_states[smallest_pin] )
    # If match( Key, Lowest Pin )
    if lkl.emission_fn( get_key, get_pins[ smallest_pin ] )
        tumbler_values_and_states[ smallest_pin ] = Base.iterate( lkl.tumbler[ smallest_pin ], tumbler_states[ smallest_pin ] )
        tumbler_values, tumbler_states = unpack_2tuples( tumbler_values_and_states )
        println("111 Kick tumbler match")
    else
        while ( !lkl.emission_fn( get_key, get_pins[ smallest_pin ] ) )
            if get_key < get_pins[ smallest_pin ]
                println("222 Kick key")
                while ( get_key < get_pins[ smallest_pin ] )
                    ( key_value, key_state ) = Base.iterate( lkl.key, key_state )
                    ( last( key_state ) > lkl.key_length ) && return nothing
                    get_key = lkl.key_lookup_fn( key_value )
                end
                key_idx = last( key_state )
                #key_value, key_state = Base.iterate( lkl.key, key_state )
            elseif get_key > get_pins[smallest_pin]
                println("333 Kick tumbler")
                while ( get_key > get_pins[ smallest_pin ] )
                    values_and_states = Base.iterate( lkl.tumbler[ smallest_pin ], tumbler_states[ smallest_pin ] )
                    tumbler_values[ smallest_pin ], tumbler_states[ smallest_pin ] = isnothing( values_and_states ) ? [nothing,nothing] : values_and_states
                    notnothing            = .!isnothing.( tumbler_values )
                    get_pins              = map( x -> isnothing(x) ? x : lkl.pin_lookup_fn( x ), tumbler_values )
                    smallest_pin          = get_smallest_pin( get_pins, notnothing )
                    #println( get_key, " && ", get_pins[ smallest_pin ] )
                    ( smallest_pin == 0 ) && return nothing
                end
                tumbler_idx = smallest_pin
                pin_idx     = last( tumbler_states[ smallest_pin ] )
                values_and_states = Base.iterate( lkl.tumbler[ smallest_pin ], tumbler_states[ smallest_pin ] )
                tumbler_values[ smallest_pin ], tumbler_states[ smallest_pin ] = isnothing( values_and_states ) ? [nothing,nothing] : values_and_states
            end
        end
    end
    return  ( key_idx => ( tumbler_idx, pin_idx ) ), ( ( key_value, key_state ) , zip( tumbler_values, tumbler_states ) )
end
