<#
  .SYNOPSIS
    Write contents of data reader to a SQL Server table.

  .DESCRIPTION
    Given a connection, data reader and table, will bulk copy data reader contents
    to a SQL Server table using System.Data.SqlClient.SqlBulkCopy

  .PARAMETER InputObject
    The source System.Data.IDataReader.

  .PARAMETER Connection
    The database connection to use.

  .PARAMETER Table
    The destination table.

  .PARAMETER BatchSize
    Rows per batch.

  .OUTPUTS 
    System.Data.SqlClient.SqlBulkCopy

  .EXAMPLE
    PS C:\> Invoke-SqlServerBulkCopy -InputObject $someDataReader -Connection (New-SqlConnection -ComputerName SQLVM01) -Table SomeTable
#>
function Invoke-SqlServerBulkCopy {
  [CmdletBinding()]
  [OutputType([System.Data.SqlClient.SqlBulkCopy])]
  param (
    
    [Parameter(Mandatory = $True,
      ValueFromPipeline = $True,
      ValueFromPipelineByPropertyName = $True)]
    [System.Data.IDataReader]$InputObject,
    
    [Parameter(Mandatory = $True)]
    [System.Data.Common.DbConnection]$Connection,
    
    [Parameter(Mandatory = $True)]
    [string] $Table,
   
    [Parameter(Mandatory = $False)]
    [int] $BatchSize,
    
    [Parameter(Mandatory = $False)]
    [int] $BulkCopyTimeout,

    [Parameter(Mandatory = $False)]
    [hashtable] $ColumnMappings) 

  begin {}

  process {
    Write-Verbose "Invoke-SqlServerBulkCopy for $($Table) on $Connection"

    try {
      $bulkCopy = New-Object System.Data.SqlClient.SqlBulkCopy($Connection)
      $bulkCopy.DestinationTableName = $Table
            
      if ($BatchSize) { 
        $bulkCopy.BatchSize = $BatchSize 
        Write-Verbose "Batch Size: $($bulkCopy.BatchSize)"
      }

      if ($BulkCopyTimeout) {
        $bulkCopy.BulkCopyTimeout = $BulkCopyTimeout
        Write-Verbose "Bulk Copy Timeout: $($bulkCopy.BulkCopyTimeout)"
      }

      if ($ColumnMappings) { 
        $bulkCopy.ColumnMappings = $ColumnMappings 
        Write-Verbose "ColumnMappings: $($bulkCopy.ColumnMappings | Format-Table -Property SourceColumn, DestinationColumn -AutoSize | Out-String)"
      }

      $bulkCopy.WriteToServer($InputObject) 

      $bulkCopy # return for disposal
    } 
    catch {
      Write-Verbose "FAILED to Invoke-SqlServerBulkCopy for $($InputObject.Connection.DataSource)"
      $PSCmdlet.ThrowTerminatingError($PSitem)
    }
  }

  end {}  
}
