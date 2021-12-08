# sccmutil
## Test-CmApplicationSupersedence.ps1
Test-CmApplicationSupersedence.ps1 defines a function `Test-CmApplicationSupersedence` that accepts a reference to a `CmApplication` object and tests that all references to applications in supersedence rules are valid.

Output is currently via the included awful function `Write-Log`.
### Example
```powershell
Get-CmApplication | Test-CmApplicationSupersedence
```
```
2021-12-08T17:08:56 - INFO - Inspecting application Java Runtime Environment (64-bit) 8u281...
2021-12-08T17:08:57 - INFO - Inspecting application Chrome Enterprise (64-bit) 83.0.4103.116...
2021-12-08T17:08:59 - WARN - Unable to resolve the application for model name ScopeId_FF477A28-8C6A-472F-83F9-7069F0617AFE/Application_dfdc9a9a-ad6b-4c22-8143-6106533be765.
2021-12-08T17:08:59 - INFO - Inspecting application Reader DC 21.007.20091...
2021-12-08T17:09:08 - INFO - Inspecting application Visual C++ Redistributable (32bit) 2008 SP1...
2021-12-08T17:09:37 - WARN - 1 applications were found with possible dead references.
```
