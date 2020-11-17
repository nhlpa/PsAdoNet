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
    [int] $BatchSize = 0,
    
    [Parameter(Mandatory = $False)]
    [int] $BulkCopyTimeout = 30,

    [Parameter(Mandatory = $False)]
    [hashtable] $ColumnMappings,

    [Parameter(Mandatory = $False)]
    [int] $NotifyAfter = 30) 

  begin {}

  process {
    $db = "$($Connection.DataSource)\$($Connection.Database)\$Table"
    Write-Verbose "Invoke-SqlServerBulkCopy for $db"

    try {
      $bulkCopy = New-Object System.Data.SqlClient.SqlBulkCopy($Connection)
      $bulkCopy.DestinationTableName = $Table
      
      if ($BatchSize -gt 0) {
        $bulkCopy.BatchSize = $BatchSize 
        Write-Verbose "Batch Size: $($bulkCopy.BatchSize)"
      }
      
      $bulkCopy.BulkCopyTimeout = $BulkCopyTimeout
      Write-Verbose "Bulk Copy Timeout: $($bulkCopy.BulkCopyTimeout)"
      
      if ($NotifyAfter -gt 0) {
        $bulkCopy.NotifyAfter = $notifyafter
        $bulkCopy.Add_SQlRowscopied( { Write-Verbose "Rows copied: $($args[1].RowsCopied)" })
      }

      if ($ColumnMappings) {         
        $ColumnMappings.GetEnumerator() | ForEach-Object {
          $bulkCopy.ColumnMappings.Add($_.Key, $_.Value)
        }
        
        Write-Verbose "ColumnMappings: $($bulkCopy.ColumnMappings | Format-Table -Property SourceColumn, DestinationColumn -AutoSize | Out-String)"
      }

      $bulkCopy.WriteToServer($InputObject) 

      $bulkCopy # return for disposal
    } 
    catch {
      Write-Verbose "FAILED to Invoke-SqlServerBulkCopy for $db"
      $PSCmdlet.ThrowTerminatingError($PSitem)
    }
  }

  end {}  
}
