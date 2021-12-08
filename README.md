# sccmutil
## Test-CmApplicationSupersedence.ps1
Test-CmApplicationSupersedence.ps1 defines a function `Test-CmApplicationSupersedence`, which accepts a reference to a CmApplication object and tests that supersedence rules refer to applications that can be resolved.
### Example
```powershell
Get-CmApplication | Test-CmApplicationSupersedence
```
