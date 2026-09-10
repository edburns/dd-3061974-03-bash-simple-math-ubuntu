## Campaign context and required reading

On the `experiment/shepherd-control` branch, the directory `3-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.

Read the entire plan before working. Then carefully re-read these exact sections:

- `## Ignorance reduction`
- `### Repository-owned validation`
- `### Output and ordering contracts`
- `## Implementation`
- `### 1. Implement Fibonacci with unit and isolated CLI coverage`

Apply these resolved decisions:

- The only canonical acceptance command is `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. The committed workflow `.github/workflows/shepherd-task-math-tool.yml` installs exactly Pester 5.7.1 and invokes that runner. Do not replace, bypass, or weaken either mechanism.
- Direct Fibonacci CLI execution writes exactly one result line to stdout in the form `Fibonacci(N) = value`.
- `Get-Fibonacci` returns only the numeric value, with no incidental output.
- Inputs are non-negative integers.
- The production and test files are the repository-root files `math-tool.ps1` and `math-tool.Tests.ps1`.
- Work is serial. This is the first task; the factorial/dispatch task starts only after this task is merged.

Research for this campaign established that repository-owned Pester validation and isolated child-process CLI tests are required to distinguish function return behavior from the script's externally observable stdout behavior. Implement production code and tests from scratch; do not copy or adapt spike source code or spike test infrastructure.

## Branch and execution order

Use `experiment/shepherd-control` from remote `origin` as the base branch for the pull request. Do not target `main`.

This is implementation subsection 1 of 2. Tasks are assigned, completed, and merged serially in plan order. Do not begin until this issue is assigned. Complete and merge this issue before subsection 2 begins.

## Implement

Create the repository-root `math-tool.ps1` with:

- A parameter named `N` constrained to non-negative integer input.
- A pure `Get-Fibonacci` function.
- Correct Fibonacci behavior for the base cases `N = 0` and `N = 1` and for larger non-negative integers.
- Direct script execution that prints exactly `Fibonacci(N) = value` as its sole result line.
- Dot-sourcing behavior that makes the function available for unit testing without emitting the direct-execution result line.

Create the repository-root `math-tool.Tests.ps1` with Pester 5.7.1 tests that:

- Dot-source `math-tool.ps1` and test `Get-Fibonacci` directly for `N = 0`, `N = 1`, and at least one small representative value greater than 1.
- Assert that function calls return the expected numeric value without incidental output.
- Start isolated child `pwsh` processes for CLI tests rather than exercising CLI behavior in the current Pester process.
- Assert the exact stdout line for the same base and representative inputs, including capitalization, parentheses, spaces, and `=`.
- Assert each valid child process exits successfully and produces no additional stdout result lines.

Keep the implementation straightforward and deterministic. Follow existing repository instructions and preserve the committed validation runner and workflow.

## Completion gates

- `math-tool.ps1` and `math-tool.Tests.ps1` are introduced together.
- Unit coverage proves `Get-Fibonacci 0` returns `0`, `Get-Fibonacci 1` returns `1`, and a representative larger input returns the correct value.
- Isolated CLI coverage proves direct execution emits exactly one correctly formatted Fibonacci result line and exits zero.
- A negative `N` is rejected rather than treated as valid input.
- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero locally.
- The pinned pull-request workflow passes without changes that bypass or weaken Pester 5.7.1 or the repository-owned runner.

## Out of scope

- Do not implement factorial or operation dispatch; those belong to subsection 2.
- Do not add unrelated operations, dependencies, generated artifacts, documentation, or repository restructuring.
- Do not modify files outside `math-tool.ps1` and `math-tool.Tests.ps1`.
- Do not modify the validation runner or workflow.
- Do not read, copy, adapt, or promote spike source code or spike test helpers into production.
