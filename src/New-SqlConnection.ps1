<#
		.SYNOPSIS
				Create a new SQL connection

		.DESCRIPTION
				Creates a new SQL Connection with the infomation provided.

		.PARAMETER ServerInstance
				The computer name where SQL server resides.

		.PARAMETER Database
				The database to connect to.

		.PARAMETER User
				The user making the connection.

		.PARAMETER Password
				The password for the connection.

		.OUTPUTS 
				System.Data.SqlClient.SqlConnection

		.EXAMPLE
				PS C:\> New-SqlConnection -ServerInstance SQLVM01
				
		.EXAMPLE
				PS C:\> New-SqlConnection -ServerInstance SQLVM01 -Database master
				
		.EXAMPLE
				PS C:\> New-SqlConnection -ServerInstance SQLVM01 -Database SOME_DB -User sa -Password abc123
#>
function New-SqlConnection {  
	[CmdletBinding()]
	[OutputType([System.Data.SqlClient.SqlConnection])]
	param (
		[Parameter(Mandatory=$True,
								ValueFromPipeline=$True,
								HelpMessage="The computer name where SQL server resides.")]
		[string] $ServerInstance,

		[Parameter(Mandatory=$False,
								HelpMessage="The database to connect to.")]
		[string] $Database,
		
		[Parameter(Mandatory=$False,
								HelpMessage="The username making the connection.")]
		[string] $User,
		
		[Parameter(Mandatory=$False,
								HelpMessage="The account password for the connection.")]
		[string] $Pwd)

	begin {
		if ($Database -ne '') {
			$databaseClause = "Database=$Database"
		}

		if ($User -ne '' -and $Pwd -ne '') {
			$connectionString = "Server=$ServerInstance;$databaseClause;User Id=$User;Password=$Pwd"
		}
		else {
			$connectionString = "Server=$ServerInstance;$databaseClause;Trusted_Connection=true"
		}
	}
	
	process {		
		Write-Verbose "New-SqlConnection for '$connectionString'"

		try {
			$connection = New-Object System.Data.SqlClient.SqlConnection    
			$connection.ConnectionString = $connectionString    
			$connection.Open()
			Write-Output $connection  
		}
		catch {      			
			Write-Verbose "FAILED to establish New-SqlConnection for '$connectionString'"
			if($connection) {
				$connection.Dispose()
				Remove-Variable -Name connection  
			}

			$PSCmdlet.ThrowTerminatingError($PSitem)
		}
	}

	end {}
}