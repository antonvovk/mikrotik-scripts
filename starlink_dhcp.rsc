:log info "Running STARLINK DHCP script"

:local rmark "STARLINK"
:local count [/ip route print count-only where comment="STARLINK"]

:if ($bound=1) do={
    :if ($count = 0) do={
        :log info "Adding route STARLINK"
        /ip route add distance=1 gateway=$"gateway-address" routing-table="STARLINK" comment="STARLINK"
    } else={
        :if ($count = 1) do={
            :local test [/ip route find where comment="STARLINK"]
            :if ([/ip route get $test gateway] != $"gateway-address") do={
                /ip route set $test gateway=$"gateway-address"
            }
        } else={
            :error "Multiple routes found"
        }
    }
} else={
    :log info "Removing route STARLINK"
    /ip route remove [find comment="STARLINK"]
}
