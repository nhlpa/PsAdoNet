<#
  .SYNOPSIS
    Create a new database command.

  .DESCRIPTION
    Creates a new System.Data.Common.DbCommand with the command and query provided.

  .PARAMETER Connection
    The Dbconnection to use.

  .PARAMETER Query
    The inline query to run. SEE -InputFile for file-based queries.

  .PARAMETER InputFile
    Filename of the query.

  .PARAMETER Parameters
    Command parameters.

  .OUTPUTS 
    System.Data.Common.DbCommand

  .EXAMPLE
    PS C:\> New-DbCommand -Connection (New-SqlConnection -ComputerName SQLVM01) -Query 'SELECT 1'
#>
function New-DbCommand {
  [CmdletBinding()]
  [OutputType([System.Data.Common.DbCommand])]
  param (    
      [Parameter(Mandatory=$True, 
                 ValueFromPipeline=$True,
                 ValueFromPipelineByPropertyName=$True,
                 HelpMessage='The database connection to use.')]
      [System.Data.Common.DbConnection] $InputObject,

      [Parameter(Mandatory=$True,
                 HelpMessage='The query to execute.')]
      [string] $Query,

      [Parameter(Mandatory=$False,
                 HelpMessage='Command parameters.')]
      [hashtable] $Parameters = @{ })

  begin {}

  process {    			
    Write-Verbose "New-DbCommand for $($InputObject.Database)"
    Write-Debug "`n$Query`n`n`n"

    try {
      $command = $InputObject.CreateCommand() 
      $command.CommandText = $Query

      foreach ($p in $Parameters.GetEnumerator()) {
        Write-Verbose "`New-DbCommand - Adding Parameter: $($p.Name) | $($p.Value)"

        $command.Parameters.AddWithValue($p.Name, $p.Value) | Out-Null
      }

      Write-Output $command
    }
    catch {
      Write-Verbose "FAILED to create New-DbCommand for $($InputObject.Database)"
      
      if($command) {
        $command.Dispose()
        Remove-Variable -Name command
      }
      
      $PSCmdlet.ThrowTerminatingError($PSitem)
    }
  }

  end {}
}