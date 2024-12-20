# PowerShell script Check_AzLbBw
The purpose of this PowerShell script is to allow a user to pull bandwidth metrics for an Azure Load Balancer (LB) over a given, user-defined time period via REST API call and split by inbound and outbound bandwidth.

Some notes on the script:
1. Time granularity is PT1M and retrieved data is in bytes - both defaults for this call
2. Retrieved data is pipped to a JSON file so a user can easily analysis via their data visualizer of choice

Installation and usage instructions:
1. Click on '<> Code button' and select 'Download ZIP'
2. Extract script to directory of choice (such as C:\azlb_bw_ps-script)
3. Move Check_AzLbBW.ps1 from the extracted folder to the folder created when extracting the .zip
4. Open a PowerShell terminal and change directory to the directory created in Step 2 with cd command. (For example: cd C:\azlb_bw_ps-script)
5. Run script with .\Check_AzLbBw.ps1
6. Provide parameters as prompted:<br>
    a. Resource ID of LB you would like to pull bandwidth metrics for - can retrieve from Azure Portal by<br>
    b. Navigating to LB you want to retrieve for > Properties (under settings tab) > Resource ID > Copy to clipboard; right click on PS terminal to paste<br>
    c. Start Time<br>
    d. End Time<br>
    e. Location you would like to save the JSON