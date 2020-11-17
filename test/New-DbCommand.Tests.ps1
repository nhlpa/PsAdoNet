BeforeAll {
  Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "\..\src\") | ForEach-Object { . $_.FullName }  
}
Describe "New-DbCommand" {
    It "Given valid DbConnection, it returns DbCommand" {        
      $conn = New-Object System.Data.SqlClient.SqlConnection
      $p = @{ 
        a = "Test" 
        b = 123 
      }
      $cmd = New-DbCommand -Connection $conn -Query "SELECT 1" -Parameters $p
      
      $cmd | Should -BeOfType System.Data.Common.DbCommand
      $cmd.CommandText | Should -BeExactly "SELECT 1"        
      $cmd.Parameters["a"].SqlValue | Should -BeExactly "Test"
      $cmd.Parameters["b"].SqlValue | Should -BeExactly 123
    }
}