<#
  .SYNOPSIS
    Execute existing DbCommand.

  .DESCRIPTION
    Provided a DbCommand will run DbCommand.ExecuteNonQuery().

  .PARAMETER InputObject
    The command to execute.

  .OUTPUTS
    int

  .EXAMPLE
    PS C:\> Invoke-DbCommandNonQuery -InputObject $someDbCommand
#>
function Invoke-DbCommand {
  [CmdletBinding()]
  [OutputType([int])]
  param (
    [Parameter(Mandatory=$True,
               ValueFromPipeline=$True,
               ValueFromPipelineByPropertyName=$True,
               HelpMessage='The command to execute.')]
    [System.Data.Common.DbCommand] $InputObject,
      
    [Parameter(HelpMessage='Execute Scalar')]
    [switch] $Scalar,

    [Parameter(HelpMessage='Execute Reader')]
    [switch] $Reader,

    [Parameter(HelpMessage='Execute Reader and fill Data Table')]
    [switch] $DataTable)

  begin {}

  process {
    Write-Verbose "Invoke-DbCommandNonQuery for $($InputObject.Connection.Database)"       
    Write-Debug "`n$($InputObject.CommandText)`n`n`n"

    try {
      if ($Scalar) {            
        Write-Output $InputObject.ExecuteScalar()
      }
      elseif ($Reader) {
        Write-Output (, $InputObject.ExecuteReader()) # ',' prevents unrolling of reader
      }
      elseif ($DataTable) {
        $tbl = New-Object System.Data.DataTable
        $rd = $InputObject.ExecuteReader()
        $tbl.Load($rd)
        $rd.Close()
        $rd.Dispose()
        Write-Output $tbl
      }
      else {
        Write-Output $InputObject.ExecuteNonQuery()
      }      
    }    
    catch {      
      Write-Verbose "FAILED to Invoke-DbCommandNonQuery for $($InputObject.Connection.Database)"
      $PSCmdlet.ThrowTerminatingError($PSitem)
    }
  }

  end {}	
}