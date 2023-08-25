:local onLine
:local runtimeLeft
:local batteryPercentage
:local lineVoltage
:local outputVoltage
:local loadPercentage

:local onLineText "%d0%96%d0%b8%d0%b2%d0%bb%d0%b5%d0%bd%d0%bd%d1%8f%20%d0%b2%d1%96%d0%b4%20%d0%b5%d0%bb%d0%b5%d0%ba%d1%82%d1%80%d0%be%d0%bc%d0%b5%d1%80%d0%b5%d0%b6%d1%96%3a%20"
:local runtimeLeftText "%d0%a7%d0%b0%d1%81%20%d1%80%d0%be%d0%b1%d0%be%d1%82%d0%b8%20%d0%b2%d1%96%d0%b4%20%d0%b1%d0%b0%d1%82%d0%b0%d1%80%d0%b5%d1%97%3a%20"
:local batteryPercentageText "%d0%97%d0%b0%d1%80%d1%8f%d0%b4%20%d0%b1%d0%b0%d1%82%d0%b0%d1%80%d0%b5%d1%97%3a%20"
:local lineVoltageText "%d0%9d%d0%b0%d0%bf%d1%80%d1%83%d0%b3%d0%b0%20%d0%b2%20%d0%b5%d0%bb%d0%b5%d0%ba%d1%82%d0%be%d0%bc%d0%b5%d1%80%d0%b5%d0%b6%d1%96%3a%20"
:local outputVoltageText "%d0%9d%d0%b0%d0%bf%d1%80%d1%83%d0%b3%d0%b0%20%d0%bd%d0%b0%20%d0%b2%d0%b8%d1%85%d0%be%d0%b4%d1%96%20%d0%9f%d0%91%d0%96%3a%20"
:local loadPercentageText "%d0%9d%d0%b0%d0%b2%d0%b0%d0%bd%d1%82%d0%b0%d0%b6%d0%b5%d0%bd%d0%bd%d1%8f%20%d0%bd%d0%b0%20%d0%9f%d0%91%d0%96%3a%20"

:local lastUpdateID 0;
:local botToken "6512233965:AAFPq5yI1wygvHy5bjPiWwxNgLdczpqJy_c";
:local SENDUNICAST do={
    :put ("Sendibg to chat id ".$2)
    /tool fetch url="https://api.telegram.org/bot$1/sendmessage?chat_id=$2&text=$3" output=user
}
:local SENDBROADCAST do={
    /tool fetch url="https://api.telegram.org/bot$1/sendmessage?chat_id=428502551&text=$2" output=user
    /tool fetch url="https://api.telegram.org/bot$1/sendmessage?chat_id=469527961&text=$2" output=user
}
:local loops 0
:local lastOnLineStatus
:local currentOnLineStatus

:while (true) do={
    /system ups {
        monitor ups1 once do={
            :if ($"on-line" = true) do={ :set ($onLine) ("%d0%9f%d1%80%d0%b8%d1%81%d1%83%d1%82%d0%bd%d1%94") } else={ :set ($onLine) ("%d0%92%d1%96%d0%b4%d1%81%d1%83%d1%82%d0%bd%d1%94") }
            :set ($runtimeLeft) ([:pick ($"runtime-left") 0 2 ]."%20%d0%b3%d0%be%d0%b4%20".[:pick ($"runtime-left") 3 5 ]."%20%d1%85%d0%b2%20".[:pick ($"runtime-left") 6 7 ]."%20%d1%81%d0%b5%d0%ba%20");
            :set ($batteryPercentage) ($"battery-charge"."%");
            :set ($lineVoltage) ([:pick ($"line-voltage") 0 3 ]."V");
            :set ($outputVoltage) ([:pick ($"output-voltage") 0 3 ]."V");
            :set ($loadPercentage) ($"load"."%");
            :set ($currentOnLineStatus) ($"on-line")
        }
    }
    :if ($lastOnLineStatus != $currentOnLineStatus && $loops = 0) do={
        :set ($lastOnLineStatus) ($"currentOnLineStatus")
    }
    :if ($lastOnLineStatus != $currentOnLineStatus && $loops != 0) do={
        :set ($lastOnLineStatus) ($"currentOnLineStatus");
        :if ($currentOnLineStatus = true) do={
            $SENDBROADCAST $botToken "%d0%95%d0%bb%d0%b5%d0%ba%d1%82%d1%80%d0%be%d0%b5%d0%bd%d0%b5%d1%80%d0%b3%d1%96%d1%8f%20%d0%b7'%d1%8f%d0%b2%d0%b8%d0%bb%d0%b0%d1%81%d1%8f"
        } else={
            $SENDBROADCAST $botToken "%d0%95%d0%bb%d0%b5%d0%ba%d1%82%d1%80%d0%be%d0%b5%d0%bd%d0%b5%d1%80%d0%b3%d1%96%d1%8f%20%d0%b7%d0%bd%d0%b8%d0%ba%d0%bb%d0%b0"
        }
    }

    :put ("Loop nr ".$loops)
    :local data ([/tool fetch url="https://api.telegram.org/bot$botToken/getUpdates?offset=$lastUpdateID" output=user as-value;]->"data")
    :local start 0
    :local end 0
    :set start ([:find $data "["]+1)
    :set end ([:len $data]-2)
    :set data [:pick $data $start $end]
    :local updates [:toarray ($data)];
    :local command ""
    :local sender ""
    :foreach update in=$updates do={
        :set $update ([:toarray $update])
        :local thisUpdateID [:pick ($update->1) 1 [:len ($update->1)]]
        :if ($thisUpdateID > $lastUpdateID) do={
            :put "New update!"
            :put ("ID: ".$thisUpdateID)
            :set lastUpdateID $thisUpdateID
            :local message ($update->5)
            :local marray [:toarray $message]
            :if (loops != 0) do={
                :for i from=0 to=([:len $marray]-1) do={
                    :if (($marray->$i) = "from") do={
                        :local val ([:toarr ($marray->([:tonum $i]+2))]->1)
                        :set sender [:pick $val 1 [:len $val]]
                    }
                    :if (($marray->$i) = "text") do={
                        :local val ($marray->([:tonum $i]+2))
                        :set command $val                    
                    }
                }
            }
        }
    }
    :if ([:len $command] > 0 && $command = "/status") do={
        $SENDUNICAST $botToken $sender ("$onLineText"."$onLine"."%0A"."$runtimeLeftText"."$runtimeLeft"."%0A"."$batteryPercentageText"."$batteryPercentage"."%0A"."$lineVoltageText"."$lineVoltage"."%0A"."$outputVoltageText"."$outputVoltage"."%0A"."$loadPercentageText"."$loadPercentage")
    }
    :set loops (loops+1)
    :delay 100ms;
}
