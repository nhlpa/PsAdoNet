BeforeAll {
  Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "\..\src\") | ForEach-Object { . $_.FullName }
  Add-Type -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath "\support\CloseableResource.cs")
}

Describe "Close-Resource" {
  It "Given $null, it does not error" {     
    $null | Close-Resource | Should -BeNullOrEmpty
  }  
  
  It "Given non-disposable, it does not error" {     
    [PSObject]@{} | Close-Resource | Should -BeNullOrEmpty
  }

  It "Given closeable & disposable, it closes & disposes" {
    $resource = [TestNamespace.CloseableResource]@{} 
    $resource | Close-Resource
    $resource.State | Should -BeExactly "Closed"
    $resource.Disposed | Should -BeExactly "Yes"
  }
}