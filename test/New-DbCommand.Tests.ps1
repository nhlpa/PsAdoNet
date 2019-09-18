$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

. (Resolve-Path "$here\..\src\$sut")

Describe "New-DbCommand" {
    It "Given valid DbConnection, it returns DbCommand" {        
      $conn = New-Object System.Data.SqlClient.SqlConnection
      $p = @{ 
        a = "Test" 
        b = 123 
      }
      $cmd = New-DbCommand -Connection $conn -Query "SELECT 1" -Parameters $p
      
      $cmd | Should -BeOfType System.Data.SqlClient.SqlCommand        
      $cmd.CommandText | Should -BeExactly "SELECT 1"        
      $cmd.Parameters["a"].SqlValue | Should -BeExactly "Test"
      $cmd.Parameters["b"].SqlValue | Should -BeExactly 123
    }
}