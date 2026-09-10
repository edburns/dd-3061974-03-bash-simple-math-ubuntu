## Campaign context and required reading

On the `experiment/shepherd-control` branch, the directory `3-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.

Read the entire plan before working. Then carefully re-read these exact sections:

- `## Ignorance reduction`
- `### Repository-owned validation`
- `### Output and ordering contracts`
- `## Implementation`
- `### 1. Implement Fibonacci with unit and isolated CLI coverage`
- `### 2. Add factorial and operation dispatch`

Apply these resolved decisions:

- The only canonical acceptance command is `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. The committed workflow `.github/workflows/shepherd-task-math-tool.yml` installs exactly Pester 5.7.1 and invokes that runner. Do not replace, bypass, or weaken either mechanism.
- Direct CLI execution writes exactly one result line to stdout: `Fibonacci(N) = value` or `Factorial(N) = value`, according to the selected operation.
- `Get-Fibonacci` and `Get-Factorial` return only numeric values, with no incidental output.
- Inputs are non-negative integers.
- The production and test files remain the repository-root files `math-tool.ps1` and `math-tool.Tests.ps1`.
- Work is serial. This task starts only from the base branch after subsection 1 has been merged.

Research for this campaign established that the existing Fibonacci unit and isolated child-process CLI tests are a required regression contract, and that the combined suite must continue to run through the repository-owned Pester runner. Implement the extension and production tests directly; do not copy or adapt spike source code or spike test infrastructure.

## Branch and execution order

Use `experiment/shepherd-control` from remote `origin` as the base branch for the pull request. Do not target `main`. Confirm that subsection 1 is already merged into that branch before making changes.

This is implementation subsection 2 of 2. Tasks are assigned, completed, and merged serially in plan order. Do not begin until this issue is assigned and subsection 1 has been merged.

## Implement

Extend the existing repository-root `math-tool.ps1` with:

- A pure `Get-Factorial` function that correctly handles all non-negative integer inputs, including `0! = 1` and `1! = 1`.
- An `Operation` parameter that dispatches between the supported `fibonacci` and `factorial` operations while retaining the `N` parameter.
- Fibonacci dispatch that preserves the behavior delivered by subsection 1.
- Factorial direct execution that prints exactly `Factorial(N) = value` as its sole result line.
- Function behavior that remains independently testable by dot-sourcing and emits no incidental output.
- Explicit rejection of unsupported operations and negative `N` values.

Extend `math-tool.Tests.ps1` with focused Pester 5.7.1 coverage. The exact organization of the additions is intentionally left to the implementation, but the resulting suite must:

- Test `Get-Factorial` directly for `N = 0`, `N = 1`, and at least one small representative value greater than 1.
- Test factorial CLI behavior in isolated child `pwsh` processes and assert the exact stdout line and successful exit.
- Retain and pass all Fibonacci function and isolated CLI coverage from subsection 1.
- Exercise operation dispatch for both supported operations so that a swapped or ignored operation cannot pass.
- Assert that valid CLI execution emits one result line only and that functions return numeric values only.

Keep the interface and tests objective and small. Follow existing repository instructions and preserve the committed validation runner and workflow.

## Completion gates

- `Get-Factorial 0` and `Get-Factorial 1` each return `1`, and a representative larger input returns the correct product.
- Isolated CLI tests prove exact factorial output formatting and successful exit.
- The combined regression suite proves both `fibonacci` and `factorial` dispatch to the correct function and output label.
- Existing Fibonacci unit and CLI behavior remains unchanged and all subsection 1 tests continue to pass.
- Unsupported operations and negative `N` values are rejected rather than producing success-shaped output.
- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero locally for the combined suite.
- The pinned pull-request workflow passes without changes that bypass or weaken Pester 5.7.1 or the repository-owned runner.

## Out of scope

- Do not add operations other than `fibonacci` and `factorial`.
- Do not rewrite or remove valid Fibonacci behavior and coverage from subsection 1.
- Do not add dependencies, generated artifacts, documentation, or unrelated repository changes.
- Keep changes limited to `math-tool.ps1` and `math-tool.Tests.ps1`.
- Do not modify the validation runner or workflow.
- Do not read, copy, adapt, or promote spike source code or spike test helpers into production.
