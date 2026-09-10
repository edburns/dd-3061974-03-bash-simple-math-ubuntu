[CmdletBinding()]
param(
    [Parameter()]
    [ValidateRange(0, 92)]
    [int] $N = 0
)

function Get-Fibonacci {
    [CmdletBinding()]
    [OutputType([long])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateRange(0, 92)]
        [int] $N
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    if ($N -eq 0) {
        return [long] 0
    }

    [long] $current = 1
    [long] $previous = 0
    for ($index = 1; $index -lt $N; $index++) {
        [long] $next = $previous + $current
        $previous = $current
        $current = $next
    }

    return $current
}

if ($MyInvocation.InvocationName -ne '.') {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
    Write-Output ('Fibonacci({0}) = {1}' -f $N, (Get-Fibonacci -N $N))
}
