$OutputFile = "BRC_Master_Backup.txt"

# 1. Initialize the file and print the visual directory tree
"========================================================================" | Out-File -FilePath $OutputFile -Encoding utf8
"                         PROJECT DIRECTORY TREE                         " | Out-File -FilePath $OutputFile -Append -Encoding utf8
"========================================================================" | Out-File -FilePath $OutputFile -Append -Encoding utf8
tree lib /F /A | Out-File -FilePath $OutputFile -Append -Encoding utf8

# 2. Add the source code section header
"`n`n========================================================================" | Out-File -FilePath $OutputFile -Append -Encoding utf8
"                              SOURCE CODE                               " | Out-File -FilePath $OutputFile -Append -Encoding utf8
"========================================================================" | Out-File -FilePath $OutputFile -Append -Encoding utf8

# 3. Loop through every single .dart file in the lib folder and append its code
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | ForEach-Object {
    $relativePath = $_.FullName.Replace($PWD.Path + '\', '')
    
    "`n`n// ========================================================================" | Out-File -FilePath $OutputFile -Append -Encoding utf8
    "// FILE: $relativePath" | Out-File -FilePath $OutputFile -Append -Encoding utf8
    "// ========================================================================`n" | Out-File -FilePath $OutputFile -Append -Encoding utf8
    
    Get-Content $_.FullName | Out-File -FilePath $OutputFile -Append -Encoding utf8
}

# 4. Grab your pubspec.yaml as well (since it has your packages/assets)
"`n`n// ========================================================================" | Out-File -FilePath $OutputFile -Append -Encoding utf8
"// FILE: pubspec.yaml" | Out-File -FilePath $OutputFile -Append -Encoding utf8
"// ========================================================================`n" | Out-File -FilePath $OutputFile -Append -Encoding utf8
Get-Content "pubspec.yaml" | Out-File -FilePath $OutputFile -Append -Encoding utf8

Write-Host "✅ Master backup successfully compiled to: $OutputFile" -ForegroundColor Green