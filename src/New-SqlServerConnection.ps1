<#
  .SYNOPSIS
    Create a new SQL connection

  .DESCRIPTION
    Creates a new SQL Connection with the infomation provided.

  .PARAMETER ServerInstance
    The computer name where SQL server resides.

  .PARAMETER Database
    The database to connect to.

  .PARAMETER Credential
    The PSCredential for the connection.

  .PARAMETER ConnectionTimeout
    The connection timeout in seconds.

  .OUTPUTS 
    System.Data.SqlClient.SqlConnection

  .EXAMPLE
    Create a new connection to a SQL Server instance using a trusted connection

    PS C:\> New-SqlServerConnection -ServerInstance SQLVM01
      
  .EXAMPLE
    Create a new connection to a SQL Server instance and specific database using a PSCredential
    
    PS C:\> New-SqlServerConnection -ServerInstance SQLVM01 -Database Northwind -Credential (Get-Credential) -ConnectionTimeout 5 

#>
function New-SqlServerConnection {  
  [CmdletBinding()]
  [OutputType([System.Data.SqlClient.SqlConnection])]
  param (
    [Parameter(Mandatory=$True,
                ValueFromPipeline=$True)]
    [string] 
    $ServerInstance,

    [Parameter(Mandatory=$False)]
    [string] 
    $Database,
    
    [Parameter(Mandatory=$False)]
    [System.Management.Automation.PSCredential] 
    $Credential,
    
    [Parameter(Mandatory=$False)]
    [Int32] 
    $ConnectionTimeout)

  begin {
    if ($Database) {
      $databaseClause = "Database=$Database"
    }

    if ($Credential) {
      $connectionString = "Server=$ServerInstance;$databaseClause;User Id=$($Credential.UserName);Password=$($Credential.GetNetworkCredential().Password)"
    }
    else {
      $connectionString = "Server=$ServerInstance;$databaseClause;Trusted_Connection=true"
    }
  }
  
  process {		
    Write-Verbose "New-SqlServerConnection for '$ServerInstance'"

    try {
      $connection = New-Object System.Data.SqlClient.SqlConnection    
      $connection.ConnectionString = $connectionString    
      $connection.Open()
      Write-Output $connection  
    }
    catch {      			
      Write-Verbose "FAILED to establish New-SqlServerConnection for '$ServerInstance'"
      Write-Debug "Connection String: $connectionString"
      if($connection) {
        $connection.Dispose()
        Remove-Variable -Name connection  
      }

      $PSCmdlet.ThrowTerminatingError($PSitem)
    }
  }

  end {}
}