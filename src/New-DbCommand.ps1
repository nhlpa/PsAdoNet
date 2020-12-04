<#
  .SYNOPSIS
    Create a new database command.

  .DESCRIPTION
    Creates a new System.Data.Common.DbCommand with the command and query provided.

  .PARAMETER Connection
    The System.Data.Common.Dbconnection to use.

  .PARAMETER Query
    The query to run. 

  .PARAMETER CommandTimeout
    The command timeout in seconds.

  .PARAMETER Parameters
    Hashtable of command parameters.

  .OUTPUTS 
    System.Data.Common.DbCommand

  .EXAMPLE    
    PS C:\> New-SqlServerConnection -ComputerName SQLVM01 | New-DbCommand -Query "SELECT 1"
#>
function New-DbCommand {
  [CmdletBinding()]
  [OutputType([System.Data.Common.DbCommand])]
  param (    
    [Parameter(Mandatory = $True, 
      ValueFromPipeline = $True,
      ValueFromPipelineByPropertyName = $True)]
    [Alias('Connection')]
    [System.Data.Common.DbConnection] 
    $InputObject,

    [Parameter(Mandatory = $True)]
    [string] $Query,

    [Parameter(Mandatory = $False)]
    [Int32] 
    $CommandTimeout = 30,

    [Parameter(Mandatory = $False)]
    [hashtable] $Parameters = @{ })

  begin {}

  process {    			
    $db = "$($InputObject.Connection.DataSource)\$($InputObject.Connection.Database)"
    Write-Verbose "New-DbCommand for $db"
    
    try {
      $command = $InputObject.CreateCommand() 
      $command.CommandText = $Query
      $command.CommandTimeout = $CommandTimeout
      
      foreach ($p in $Parameters.GetEnumerator()) {
        Write-Debug "`New-DbCommand - Adding Parameter: $($p.Name) | $($p.Value)"

        $command.Parameters.AddWithValue($p.Name, $p.Value) | Out-Null
      }

      Write-Output $command
    }
    catch {
      Write-Verbose "FAILED to create New-DbCommand for $db"
      
      if ($command) {
        $command.Dispose()
        Remove-Variable -Name command
      }
      
      $PSCmdlet.ThrowTerminatingError($PSitem)
    }
  }

  end {}
}