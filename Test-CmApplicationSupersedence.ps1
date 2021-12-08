Function Write-Log
{
    [cmdletbinding(DefaultParameterSetName = 'Default')]
    param(
        
        # The path to the log file
        [Parameter(
            ParameterSetName = 'File',
            Mandatory=$true)]
        [String]
        $Path,

        # The message string to be logged
        [Parameter(
            ValueFromPipeline,
            Mandatory=$true)]
        [String]
        $Message,

        # The classification level of the messsage: INFO (default), WARN, ERROR or SUCCESS
        [ValidateSet("INFO","WARN","ERROR","SUCCESS")]
        [String]
        $Level = "INFO",

        # The datetime format to use within logs. Default is 's' yyyy-MM-dd'T'HH:mm:ss
        # See: https://docs.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings
        [String]
        $DateTimeFormat = "s" 
    )
     
    Begin {
        $ColourMap = @{
            SUCCESS = "Green";
            WARN    = "Yellow";
            ERROR   = "Red";
            INFO    = "White";
        }
    }
 
    Process {
        $Now = ([DateTime]::Now).toString($DateTimeFormat)
        $LogLine = "{0} - {1} - {2}" -f $Now, $($Level.ToUpper()), $Message

        If($Path) {   
            $LogLine | Out-File -Append $Path -ErrorAction Stop -Encoding utf8
        }

        $LogLine | Write-Host -ForegroundColor $ColourMap.$Level
    }
 
    End { }
}

Function Test-CmApplicationSupersedence {

    [cmdletBinding(DefaultParameterSetName="CmApplication")]

    param (
        [Parameter(
            ParameterSetName="ApplicationName",
            Mandatory=$True,
            Position=1)]
        [String]
        $Name,

        [Parameter(
            ParameterSetName="ApplicationModelName",
            Mandatory=$True,
            Position=1
         )]
        [String]
        $ModelName,

        [Parameter(
            ParameterSetName="CmApplication",
            Mandatory=$True,
            Position=1,
            ValueFromPipeline=$True
         )]
        [Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlResultObject]
        $Application
    )

    Begin {
        $ProblematicApplicationList = New-Object System.Collections.ArrayList
    }

    Process {
        Switch ($PsBoundParameters) {
            { $_.Name } { 
                $Application = Get-CmApplication -Name $_.Name
                If($Null -eq $Application) {
                    Throw [System.Exception]"Unable to resolve application via name {0}" -f $_.Name
                }
            }
            { $_.ModelName }  {
                $Application = Get-CmApplication -ModelName $_.ModelName
                If($Null -eq $Application) {
                    Throw [System.Exception]"Unable to resolve application via model name {0}" -f $_.Name
                }
            }
            { $_.Application } {
                
            }
        }


        Write-Log -Message "Inspecting application $($Application.LocalizedDisplayName)..."

        $PackageXML = [xml]($Application.SDMPackageXML)
        $SupersededApplicationReferenceList = $PackageXML.AppMgmtDigest.DeploymentType.Supersedes.DeploymentTypeRule.DeploymentTypeIntentExpression.DeploymentTypeApplicationReference
        
        If($SupersededApplicationReferenceList) {
            ForEach($SupersededApplicationReference in $SupersededApplicationReferenceList) { 
                $SupersededApplicationModelName = "{0}/{1}"-f $SupersededApplicationReference.AuthoringScopeId, $SupersededApplicationReference.LogicalName
            
                # Write-Log -Message "Resolving superseded application for reference model name $SupersededApplicationModelName..."
                $SupersededApplication = Get-CMApplication -ModelName $SupersededApplicationModelName

                If($Null -ne $SupersededApplication) {
                    #Write-Log -Level SUCCESS -Message "Model name $SupersededApplicationModelName resolves to $($SupersededApplication.LocalizedDisplayName)."
                }
                Else {
                    Write-Log -Level WARN -Message "Unable to resolve the application for model name $SupersededApplicationModelName."
                    $ProblematicApplicationList.Add($Application) | Out-Null
                }
            }
        }
        Else {
            # Write-Log -Message "$($Application.LocalizedDisplayName) does not contain any supersedence rules."
        }

    }

    End {
        If($ProblematicApplicationList.Count) {
            $Level = "WARN"
        }
        Else {  
            $Level = "SUCCESS"
        }
        
        Write-Log -Level $Level -Message "$($ProblematicApplicationList.Count) applications were found with possible dead references."
        
    }
}
