# Create connection to SQL database (Enter $server and $database names)
$server = "ENTER SERVER NAME"
$database = "ENTER DB NAME"
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = “Server=$server;Integrated Security=true;Initial Catalog=$database”
$connection.Open()
$cmd = New-Object System.Data.SqlClient.SqlCommand
$cmd.connection = $connection

$date = Get-Date -Format "MM/dd/yy"
$yesterday = (Get-Date(get-date).AddDays(-1) -Format "MM/dd/yy")

# Enter your wallet address that is being mined to (Remove Ox)
$wallet = "ENTER WALLET ADDRESS"

# Ethermine API endpoint for general stats
$uri = "https://api.ethermine.org/miner/" + $wallet + "/currentStats"
$response = Invoke-RestMethod $uri -Method "GET"

# Retrieve different statistics
$unpaidBalance = $response.data.unpaid
$workers = $response.data.activeWorkers

if($workers -eq $null){
    $workers = "Worker is Inactive"
}

$averageHashRate = $response.data.averageHashrate
$coinsPerMin = $response.data.coinsPerMin
$coinsPerDay = $coinsPerMin * 60 *24
$usdPerMin = $response.data.usdPerMin
$usdPerDay = $usdPerMin * 60 * 24

# Compare todays ETH balance to yesterdays (from SQL database) to evaluate daily growth
$query = "Select UnpaidBalance FROM Ethermine_Dashboard WHERE Date = '$yesterday'"
$cmd.CommandText = $query
$yesterdaysBalance = $cmd.ExecuteScalar()
$dailyChange = $unpaidBalance - $yesterdaysBalance

# Push to SQL database
$cmd.CommandText = "INSERT INTO Ethermine_Dashboard (Date,UnpaidBalance,DailyChange,ActiveWorkers,AvgHash,CoinsPerMin,CoinsPerDay,UsdPerMin,UsdPerDay) VALUES('$date','$unpaidBalance','$dailyChange','$workers','$averageHashRate','$coinsPerMin','$coinsPerDay','$UsdPerMin','$UsdPerDay')"
$cmd.ExecuteNonQuery() | Out-Null
$connection.close()