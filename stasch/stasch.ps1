Param (
    [string]$path,
    [string]$datafile= "hash-table",
    [string]$compare
)


# function copied from Technet Script Gallery 
#http://jongurgul.com/blog/get-stringhash-get-filehash/ 
Function Get-StringHash([String] $String,$HashName = "MD5") 
{ 
    $StringBuilder = New-Object System.Text.StringBuilder 
    [System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{ 
        [Void]$StringBuilder.Append($_.ToString("x2")) 
    } 
    $StringBuilder.ToString() 
}


# created a function of an old script that spat out cryptographic sums of files. 
Function shasum ([switch]$md5,[switch]$sha256,$filename) 
{
    $sha1object = new-Object System.Security.Cryptography.SHA1Managed
    $md5object = new-Object System.Security.Cryptography.MD5CryptoServiceProvider
    $sha256object = new-Object System.Security.Cryptography.SHA256Managed 
    $file = [System.IO.File]::Open($filename, "open", "read")
    $output = New-Object System.Text.StringBuilder 
    if ($md5) { 
        $md5object.ComputeHash($file) | %{ 
                [Void]$output.Append($_.ToString("x2"))} 
    } elseif ($sha256) { 
    
        $sha256object.ComputeHash($file) | %{ 
                [Void]$output.Append($_.ToString("x2"))} 
    } else { 
    
        $sha1object.ComputeHash($file) | %{ 
                [Void]$output.Append($_.ToString("x2"))} 
    } 
 
    $file.Dispose()
    $output.ToString() 
}

# this function looks through the old file inventory and detects any changes 
Function record_search ($record,$old_records)
{
    
$new_id = $record.id 
$new_signature = $record.signature
$new_file_name = $record.file_name 
foreach ($old_record in $old_records) {
    $old_id = $old_record.id 
    $old_signature = $old_record.signature
    $old_file_name = $old_record.file_name  
#    Write-Host $new_id, $old_id
#    Write-Host $new_signature, $old_signature 
    if (($old_signature -cnotcontains $new_signature) -and ($old_id -ccontains $new_id))
        {Write-Host "$old_file_name has changed"} 
    elseif (($old_signature -contains $new_signature) -and ($old_id -cnotcontains $new_id)) 
        {
            # need to traverse the known file table again to check if the dupe files is already known. 
            foreach ($old_record in $old_records) { 
                if (($old_record.signature -contains $new_signature) -and ($old_record.id -contains $new_id))
                    {$known_dupe = 1}           
                }
            if ($known_dupe -eq 0)
            {{Write-Host "$new_file_name may be a copy of $old_file_name"}}
        }
#    elsif  (($old_signature -cn))
}

}

# this function finds inventory changes in the new and old file inventory (ie file additions and deletions)
Function file_inventory_check($new, $old)
{
 $results = Compare-Object $new.id $old.id 
 foreach ($result in $results) {
     [string]$SideIndicator = $result.SideIndicator
     [string]$changed_id = $result.InputObject  
     if($SideIndicator -contains "<=") # entry is only in the old file inventory, ie deleted file 
        {
            $changes = $new| ?{ $_.id -contains $changed_id}
             
        foreach ($change in $changes) {
        Write-Host "$($change.file_name) has been added."}}
        
    elseif ($SideIndicator -contains "=>") # entry is only the new file inventory, ie added file
       {
        $changes = $old | ?{ $_.id -contains $changed_id }
           
        foreach ($change in $changes) {
        Write-Host "$($change.file_name) has been deleted."}}
    } 
}


$directory = Get-ChildItem $path -recurse

if (Test-Path $datafile){ $old_file_inventory = Import-Csv $home\$datafile}

$files =  $directory | where {($_.extension -eq '.ps1' -or $_.extension -eq '.exe' -or $_.extension -eq ".dll" -or $_.extension -eq ".config")} # finds all files with exes in user supplied path. 
$current_file_inventory = @() 
foreach ($file in $files) {
    $file_objects = New-Object psobject
    $hash_id = Get-StringHash -String $file.FullName
    $hash_signature = shasum -filename $file.Fullname  
    #Write-Host $hash_id, $file.FullName, $hash_signature
    Add-Member -InputObject $file_objects -MemberType NoteProperty -Name id -Value $hash_id 
    Add-Member -InputObject $file_objects -MemberType NoteProperty -Name file_name -Value $file.FullName
    Add-Member -InputObject $file_objects -MemberType NoteProperty -Name signature -Value $hash_signature
    if($old_file_inventory) {record_search -record $file_objects -old_records $old_file_inventory} 
    $current_file_inventory += $file_objects 
}

# Compare-Object $old_file_inventory $current_file_inventory -Passthru 
if($old_file_inventory) {file_inventory_check -new $current_file_inventory -old $old_file_inventory} 

$current_file_inventory | Export-Csv -NoTypeInformation $home\$datafile

