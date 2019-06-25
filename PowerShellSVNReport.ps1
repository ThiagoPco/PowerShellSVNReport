# The number of the revisions to be analyzed
$numberOfRevisions = 100

#The root project folder
$initialProjectPath = 'C:\projects\project1'

# Custom Header
$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

Write-Host "Setting the initial path: $initialProjectPath"
cd $initialProjectPath

Write-Host "Generating file svn.xml..."

svn log -v --xml -l $numberOfRevisions > svn.xml

Write-Host "svn.xml generated with success..."

[xml] $xmlDoc = [xml] (Get-Content .\svn.xml)

$o = @{}

$xmlDoc.log.logentry.paths.path | ForEach-Object {   
     if($_.kind -eq 'file' -And  $_.action -eq 'M'){
        if(!$o.Contains($_.InnerText)){
            $o.Add($_.InnerText, 1)
        }else {
            $o[$_.InnerText] = $o[$_.InnerText] + 1
        }
     }
}

$o.GetEnumerator() | sort -Property value -Descending | ConvertTo-Html -Property Key,Value -Head $Header | Out-File -FilePath SVNReport.html
