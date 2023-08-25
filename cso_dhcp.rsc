:log info "Running CSO DHCP script"

:local rmark "CSO"
:local count [/ip route print count-only where comment="CSO"]

:if ($bound=1) do={
    :if ($count = 0) do={
        :log info "Adding route CSO"
        /ip route add distance=1 gateway=$"gateway-address" routing-table="CSO" comment="CSO"
        :log info "Adding route MAIN"
        /ip route add distance=1 gateway=$"gateway-address" comment="MAIN"
    } else={
        :if ($count = 1) do={
            :local test [/ip route find where comment="CSO"]
            :if ([/ip route get $test gateway] != $"gateway-address") do={
                /ip route set $test gateway=$"gateway-address"
            } 
        } else={
            :error "Multiple routes found"
        }
    }
} else={
    :log info "Removing route CSO"
    /ip route remove [find comment="CSO"]
    :log info "Removing route MAIN"
    /ip route remove [find comment="MAIN"]
}
