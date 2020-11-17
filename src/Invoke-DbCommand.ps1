<#
  .SYNOPSIS
    Execute existing DbCommand.

  .DESCRIPTION
    Provided a DbCommand will run DbCommand.ExecuteNonQuery().

  .PARAMETER InputObject
    The command to execute.

  .PARAMETER Scalar
    Execute command and return a scalar (single) value

  .PARAMETER Reader
    Execute command and return System.Data.IDataReader

  .PARAMETER DataTable
    Execute command and return System.Data.DataTable

  .INPUTS
    System.Data.Common.DbCommand

  .OUTPUTS
    int (default)

    IDataReader (-Reader)
    
    DataTable (-DataTable)

    Object (-Scalar)
    
  .EXAMPLE
    PS C:\> Invoke-DbCommand -InputObject $someDbCommand
#>
function Invoke-DbCommand {
  [CmdletBinding()]
  [OutputType([int])]
  param (
    [Parameter(Mandatory = $True,
      ValueFromPipeline = $True,
      ValueFromPipelineByPropertyName = $True)]
    [System.Data.Common.DbCommand] $InputObject,
      
    [Parameter(HelpMessage = "Execute Scalar")]
    [switch] $Scalar,

    [Parameter(HelpMessage = "Execute Reader")]
    [switch] $Reader,

    [Parameter(HelpMessage = "Execute Reader and fill Data Table")]
    [switch] $DataTable)

  begin {}

  process {
    Write-Verbose "Invoke-DbCommand for $($InputObject.Connection.DataSource)"       
    Write-Debug "`n$($InputObject.CommandText)`n`n`n"

    try {
      if ($Scalar) {            
        Write-Output $InputObject.ExecuteScalar()
      }
      elseif ($Reader) {
        # Write-Output (, $InputObject.ExecuteReader()) # ',' prevents unrolling of reader
        Write-Output ($InputObject.ExecuteReader()) -NoEnumerate
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
      Write-Verbose "FAILED to Invoke-DbCommand for $($InputObject.Connection.DataSource)"
      $PSCmdlet.ThrowTerminatingError($PSitem)
    }
  }

  end {}	
}