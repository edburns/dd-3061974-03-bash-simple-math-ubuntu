BeforeAll {
    $script:ScriptPath = Join-Path $PSScriptRoot 'math-tool.ps1'
    . $script:ScriptPath

    $script:PwshPath = (Get-Process -Id $PID).Path

    function Invoke-MathToolCli {
        param(
            [Parameter(Mandatory = $true)]
            [string[]] $ScriptArguments
        )

        $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
        $startInfo.FileName = $script:PwshPath
        $startInfo.UseShellExecute = $false
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        foreach ($argument in @('-NoLogo', '-NoProfile', '-File', $script:ScriptPath) + $ScriptArguments) {
            $startInfo.ArgumentList.Add($argument)
        }

        $process = [System.Diagnostics.Process]::Start($startInfo)
        $standardOutputTask = $process.StandardOutput.ReadToEndAsync()
        $standardErrorTask = $process.StandardError.ReadToEndAsync()
        $process.WaitForExit()
        $standardOutput = $standardOutputTask.GetAwaiter().GetResult()
        $null = $standardErrorTask.GetAwaiter().GetResult()

        $lines = if ([string]::IsNullOrEmpty($standardOutput)) {
            @()
        }
        else {
            @((($standardOutput -replace '\r?\n\z', '') -split '\r?\n'))
        }

        return [pscustomobject]@{
            ExitCode = $process.ExitCode
            Lines    = @($lines)
        }
    }
}

Describe 'Get-Fibonacci' {
    It 'returns 0 for N = 0' {
        Get-Fibonacci -N 0 | Should -Be 0
    }

    It 'returns 1 for N = 1' {
        Get-Fibonacci -N 1 | Should -Be 1
    }

    It 'returns 55 for N = 10' {
        Get-Fibonacci -N 10 | Should -Be 55
    }

    It 'returns only the numeric value without incidental output' {
        $result = @(Get-Fibonacci -N 10)
        $result.Count | Should -Be 1
        $result[0] | Should -BeOfType [long]
        $result[0] | Should -Be 55
    }

    It 'rejects a negative N' {
        { Get-Fibonacci -N -1 } | Should -Throw
    }
}

Describe 'math-tool.ps1 dot-sourcing' {
    It 'does not change caller strict mode or error preference' {
        $callerState = & {
            Set-StrictMode -Off
            $ErrorActionPreference = 'Continue'
            . $script:ScriptPath

            $strictModeUnchanged = $null -eq $undefinedVariable
            [pscustomobject]@{
                ErrorActionPreference = $ErrorActionPreference
                StrictModeUnchanged   = $strictModeUnchanged
            }
        }

        $callerState.ErrorActionPreference | Should -Be 'Continue'
        $callerState.StrictModeUnchanged | Should -BeTrue
    }
}

Describe 'math-tool.ps1 direct execution' {
    It 'writes exactly one result line for N = <N>' -ForEach @(
        @{ N = 0; Expected = 'Fibonacci(0) = 0' }
        @{ N = 1; Expected = 'Fibonacci(1) = 1' }
        @{ N = 10; Expected = 'Fibonacci(10) = 55' }
    ) {
        $invocation = Invoke-MathToolCli -ScriptArguments @('-N', "$N")

        $invocation.ExitCode | Should -Be 0
        $invocation.Lines.Count | Should -Be 1
        $invocation.Lines[0] | Should -BeExactly $Expected
    }

    It 'rejects a negative N' {
        $invocation = Invoke-MathToolCli -ScriptArguments @('-N', '-1')

        $invocation.ExitCode | Should -Not -Be 0
        $invocation.Lines | Should -BeNullOrEmpty
    }
}
