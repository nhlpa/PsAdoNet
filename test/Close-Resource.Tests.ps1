$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

. (Resolve-Path "$here\..\src\$sut")

Describe "Close-Resource" {
    It "Given non-disposable, it does not error" {
        [PSObject]@{} | Close-Resource | Should -BeNullOrEmpty
    }

    It "Given closeable & disposable, it closes & disposes" {
        Add-Type -LiteralPath (Resolve-Path "$here\..\.etc\CloseableResource.cs")

        $resource = [TestNamespace.CloseableResource]@{} 
        $resource | Close-Resource

        $resource.State | Should -BeExactly "Closed"
        $resource.Disposed | Should -BeExactly "Yes"
    }
}