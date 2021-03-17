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
    
    [Parameter(Mandatory = $True, ParameterSetName = "Reader", ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
    [Alias("Reader", "DataReader")]
    [System.Data.IDataReader]$InputObject,

    [Parameter(Mandatory = $True, ParameterSetName = "DataTable", ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
    [System.Data.DataTable]$DataTable,
    
    [Parameter(Mandatory = $True, ParameterSetName = "Reader")]
    [Parameter(Mandatory = $True, ParameterSetName = "DataTable")]
    [System.Data.Common.DbConnection]$Connection,
    
    [Parameter(Mandatory = $True, ParameterSetName = "Reader")]
    [Parameter(Mandatory = $True, ParameterSetName = "DataTable")]
    [string] $Table,
   
    [Parameter(Mandatory = $False, ParameterSetName = "Reader")]
    [Parameter(Mandatory = $False, ParameterSetName = "DataTable")]
    [int] $BatchSize = 0,
    
    [Parameter(Mandatory = $False, ParameterSetName = "Reader")]
    [Parameter(Mandatory = $False, ParameterSetName = "DataTable")]
    [int] $BulkCopyTimeout = 30,

    [Parameter(Mandatory = $False, ParameterSetName = "Reader")]
    [Parameter(Mandatory = $False, ParameterSetName = "DataTable")]
    [hashtable] $ColumnMappings,

    [Parameter(Mandatory = $False, ParameterSetName = "Reader")]
    [Parameter(Mandatory = $False, ParameterSetName = "DataTable")]
    [int] $NotifyAfter = 30,
    
    [Parameter(Mandatory = $False, ParameterSetName = "Reader")]
    [Parameter(Mandatory = $False, ParameterSetName = "DataTable")]
    [System.Data.SqlClient.SqlBulkCopyOptions] $Options = [System.Data.SqlClient.SqlBulkCopyOptions]::Default) 

  begin {
    $db = "$($Connection.DataSource)\$($Connection.Database)\$Table"
    Write-Verbose "Invoke-SqlServerBulkCopy for $db"
  }
  process {    
    try {      
      $bulkCopy = New-Object System.Data.SqlClient.SqlBulkCopy($Connection, $Options, $null)
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

      if ($DataTable) { $bulkCopy.WriteToServer($DataTable) }
      else { $bulkCopy.WriteToServer($InputObject) }

      $bulkCopy # return for disposal
    } 
    catch {
      Write-Verbose "FAILED to Invoke-SqlServerBulkCopy for $db"
      $PSCmdlet.ThrowTerminatingError($PSitem)
    }
  }
  end {}  
}
