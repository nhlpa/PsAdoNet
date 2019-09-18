<#
		.SYNOPSIS
				Write contents of data reader to a SQL Server table.

		.DESCRIPTION
				Given a connection, data reader and table, will bulk copy data reader contents
				to a SQL Server table using System.Data.SqlClient.SqlBulkCopy

		.PARAMETER InputObject
				The source data reader.

		.PARAMETER Connection
				The database connection to use.

		.PARAMETER Table
				The destination table.

		.PARAMETER BatchSize
				Rows per batch.

		.OUTPUTS 
				System.Data.SqlClient.SqlBulkCopy

		.EXAMPLE
				PS C:\> Write-SqlBulkCopy -InputObject $someDataReader -Connection (New-SqlConnection -ComputerName SQLVM01) -Table SomeTable
#>
function Invoke-SqlBulkCopy {
	[CmdletBinding()]
	[OutputType([System.Data.SqlClient.SqlBulkCopy])]
	param (
		
		[Parameter(Mandatory=$True,
							 ValueFromPipeline=$True,
							 ValueFromPipelineByPropertyName=$True,
							 HelpMessage='The source data reader.')]
		[System.Data.IDataReader]$InputObject,
		
		[Parameter(Mandatory=$True,               
							 HelpMessage='The database connection to use.')]
		[System.Data.Common.DbConnection]$Connection,
		
		[Parameter(Mandatory=$True,
							 HelpMessage='The destination table.')]
		[string] $Table,

		[Parameter(Mandatory=$False,
							 HelpMessage='Rows per batch.')]
		[int] $BatchSize = 2000) 

	begin {}

	process {
		Write-Verbose "Write-SqlBulkCopy: $($bulkCopy.DestinationTableName) / Batch Size: $($bulkCopy.BatchSize)"

		try {
			$bulkCopy = New-Object System.Data.SqlClient.SqlBulkCopy($Connection)
			$bulkCopy.DestinationTableName = $Table
			
			if ($BatchSize) { $bulkCopy.BatchSize = $BatchSize }

			$bulkCopy.WriteToServer($InputObject) 

			$bulkCopy # return for disposal
		} 
		catch {
			$PSCmdlet.ThrowTerminatingError($PSitem)
		}
	}

	end {}  
}
