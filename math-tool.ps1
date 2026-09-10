[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('fibonacci', 'factorial')]
    [string] $Operation = 'fibonacci',

    [Parameter()]
    [ValidateRange(0, 2147483647)]
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

function Get-Factorial {
    [CmdletBinding()]
    [OutputType([System.Numerics.BigInteger])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateRange(0, 2147483647)]
        [int] $N
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    [System.Numerics.BigInteger] $result = 1
    for ($factor = 2; $factor -le $N; $factor++) {
        $result *= $factor
    }

    return $result
}

if ($MyInvocation.InvocationName -ne '.') {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
    switch ($Operation) {
        'fibonacci' {
            Write-Output ('Fibonacci({0}) = {1}' -f $N, (Get-Fibonacci -N $N))
        }
        'factorial' {
            Write-Output ('Factorial({0}) = {1}' -f $N, (Get-Factorial -N $N))
        }
    }
}
