Clear-Host
Remove-Variable * -ErrorAction SilentlyContinue

# 1. 載入 System.Data.SQLite.dll
Add-Type -Path "c:\sqlite\System.Data.SQLite.dll"

# 2. 連接到 SQLite 資料庫（不存在時會自動建立）
$dbPath = "c:\sqlite\GeoDB.db"
$connectionString = "Data Source=$dbPath;Version=3;"
$connection = New-Object System.Data.SQLite.SQLiteConnection($connectionString)
$connection.Open()

# 3. 建立資料表
$sqlCreateTable = "CREATE TABLE IF NOT EXISTS GeoInfo (Id INTEGER PRIMARY KEY, ip TEXT, isp TEXT, `
continent TEXT, continent_code TEXT, country TEXT, country_code TEXT, `
city TEXT, timezone TEXT, lat TEXT, lon TEXT, currency TEXT, currency_name TEXT, asn TEXT, asn_number TEXT);"
$command = $connection.CreateCommand()
$command.CommandText = $sqlCreateTable
$command.ExecuteNonQuery()

# 欄位順序
$order = @("ip", "isp", "continent", "continent_code", "country", "country_code", `
"city", "timezone", "lat", "lon", "currency", "currency_name", "asn", "asn_number")

# 設定有序的 Hashtable
# 此為測試資料，隨便亂打的，請勿當真 XD
$info = [ordered]@{
    ip = "192.168.1.1"
    isp = "Hinet"
    lat = "25"
    lon = "123"
    city = "Taipei"
    country_code = "TW"
    country = "Taiwan ROC"
    continent_code = "AS"
    continent = "Asia"
    timezone = "UTC(+8)"
    asn_number = "12345"
    asn = "AS123"
    currency = "NTD"
    currency_name = "New Taiwan Dollar"
}

# 4. 插入資料
# 將所有欄位組成字串
$fields = $order -join ", "
# 將 info Hashtable 依照 $order 欄位順序轉換成字串陣列
$values = $order | ForEach-Object { '"' + $info[$_] + '"' }
# 將字串陣列轉換成字串
$valuesString = $values -join ", "
# 產生 SQL INSERT INTO 語法
$sqlInsert = "INSERT INTO GeoInfo ($fields) VALUES ($valuesString);"
$command.CommandText = $sqlInsert
$command.ExecuteNonQuery()

# 5. 讀取資料
$sqlSelect = "SELECT * FROM GeoInfo;"
$command.CommandText = $sqlSelect
$reader = $command.ExecuteReader()
while ($reader.Read()) {
	# 按照 欄位順序讀取資料並輸出
    $order | ForEach-Object {
        $fieldname = $_
        Write-Host ("{0}: {1}, " -f $fieldname, $reader[$fieldname]) -NoNewline
    }
    Write-Host
}
$reader.Close()

# 6. 關閉連接
$connection.Close()