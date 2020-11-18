BeforeAll {
    Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "\..\src\") | ForEach-Object { . $_.FullName }    
}

Describe "ConvertTo-DataTable" {
    It "Give null, it returns empty DataTable" {
        [System.Data.DataTable]$dt = $null | ConvertTo-DataTable
        $dt.Rows.Count | Should -Be 0
        $dt.Columns.Count | Should -Be 0        
    }

    It "Given PSObject[], it creates DataTable" {            
        [System.Data.DataTable]$dt = [PSCustomObject]@{Id = 1; Description = "Description" } | ConvertTo-DataTable
        $dt.Rows.Count | Should -Be 1
        $dt.Columns.Count | Should -Be 2        
        $dt.Rows[0]["Id"] | Should -Be 1
        $dt.Rows[0]["Description"] | Should -Be "Description"
    }

    It "Given PSObject[], it creates DataTable for specified columns" {            
        [System.Data.DataTable]$dt = [PSCustomObject]@{Id = 1; Description = "Description" } | ConvertTo-DataTable -Columns Id
        $dt.Rows.Count | Should -Be 1
        $dt.Columns.Count | Should -Be 1    
        $dt.Rows[0]["Id"] | Should -Be 1
    }
}