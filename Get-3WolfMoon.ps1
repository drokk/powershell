Function Get-MoonPhase {
    <#
    .SYNOPSIS
    Calculate approximate moon phase.
    .DESCRIPTION
    Moon phase code converted by Mohawke, 2019
    .PARAMETER Year
    Specifies the year.
    .PARAMETER Month
    Specifies the month.
    .PARAMETER Day
    Specifies the day.
    #>
    Param (
        [Parameter(Mandatory=$True)]
     [string]$Year,
        [Parameter(Mandatory=$True)]
     [string]$Month,
        [Parameter(Mandatory=$True)]
     [string]$Day
    )
    $lunar_cycle = 29.530588853
    $ref_date = get-date -Year 2000 -Month 1 -Day 6 # Jan. 6. 2000 [New Moon]
    $usr_date = get-date -Year $Year -Month $Month -Day $Day
    $phases = @("new",
                "waxing crescent",
                "first quarter",
                "waxing gibbous",
                "full",
                "waning gibbous",
                "last quarter",
                "waning crescent")
    $phase_length = $lunar_cycle / 8
    $days = ($usr_date - $ref_date).Days
    $mdays = ($days + $phase_length / 2) % $lunar_cycle
    $phase_index = [int]($mdays * (8 / $lunar_cycle)) - 1
    
    Write-Host "length $phase_length days $days mday $mdays index $phase_index" 
    return $phases[$phase_index]
}
$moonphase = Get-MoonPhase -Year 2019 -Month 11 -Day 12
Write-Host $moonphase