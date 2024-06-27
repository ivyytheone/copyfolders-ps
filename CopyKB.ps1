# Path to the folder you want to copy
$sourceFolder = "C:\Path\To\Your\Folder"

# Path to the text file containing the list of computer names
$computerListPath = "C:\Path\To\Your\ComputerList.txt"

# Get credentials for admin access (replace 'username' and 'password' with appropriate admin credentials)
$adminCredentials = Get-Credential -Credential "Username" "Password"

# Read the list of computer names from the text file
$computerNames = Get-Content -Path $computerListPath

foreach ($computerName in $computerNames) {
    # Test connection to the remote computer
    $connectionTest = Test-Connection -ComputerName $computerName -Count 1 -Quiet
    
    if ($connectionTest) {
        try {
            # Define script block to execute on remote computer
            $scriptBlock = {
                param($sourceFolder, $adminCred)
                
                # Construct the destination path on the remote computer
                $destinationFolder = "C:\Destination\Folder"  # Modify this path as needed
                
                try {
                    # Copy the folder to the remote computer
                    Copy-Item -Path $using:sourceFolder -Destination $using:destinationFolder -Recurse -Force
                    
                    # Display success message
                    Write-Host "Copied $using:sourceFolder to $($env:COMPUTERNAME)" -ForegroundColor Green
                }
                catch {
                    # Display an error message if the copy operation fails
                    Write-Host "Failed to copy $using:sourceFolder to $($env:COMPUTERNAME). $_.Exception.Message" -ForegroundColor Red
                }
            }

            # Invoke the script block on the remote computer with admin privileges
            Invoke-Command -ComputerName $computerName -ScriptBlock $scriptBlock -Credential $adminCredentials -ArgumentList $sourceFolder
        }
        catch {
            Write-Host "Failed to copy on $computerName: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "$computerName is not online" -ForegroundColor Yellow
    }
}
