[CmdletBinding()]
param(
    [Parameter()]
    [ValidateRange(0, [int]::MaxValue)]
    [int] $N = 0
)

function Get-Fibonacci {
    [CmdletBinding()]
    [OutputType([long])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateRange(0, [int]::MaxValue)]
        [int] $N
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    [long] $previous = 0
    [long] $current = 1
    for ($index = 0; $index -lt $N; $index++) {
        [long] $next = $previous + $current
        $previous = $current
        $current = $next
    }

    return $previous
}

if ($MyInvocation.InvocationName -ne '.') {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
    Write-Output ('Fibonacci({0}) = {1}' -f $N, (Get-Fibonacci -N $N))
}
