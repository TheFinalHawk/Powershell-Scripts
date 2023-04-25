# Define path to computer list file
$computerListPath = "C:\Users\altgbc\Documents\CheckMMA\computerlist.txt"

# Define path to output file
$outputPath = "C:\Users\altgbc\Documents\CheckMMA\ouputs\output.csv"

# Create an array to hold the results
$results = @()

# Read the computer list file
$computers = Get-Content -Path $computerListPath

# Loop through each computer in the list
foreach ($computer in $computers) {
    # Create a remote session to the computer
    $session = New-PSSession -ComputerName $computer
    
    # Invoke the script on the remote session
    $result = Invoke-Command -Session $session -ScriptBlock {
        # Check if Microsoft Monitoring Agent is installed
        $mma = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "Microsoft Monitoring Agent*"}
        if ($mma -ne $null) {
            $installed = "Yes"
        } else {
            $installed = "No"
        }
        # Output the computer name and installation status
        [PSCustomObject]@{
            ComputerName = $env:COMPUTERNAME
            AgentInstalled = $installed
        }
    }
    
    # Add the result to the results array
    $results += $result
    
    # Close the remote session
    Remove-PSSession -Session $session
}

# Export the results to a CSV file
$results | Export-Csv -Path $outputPath -NoTypeInformation
