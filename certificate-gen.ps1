if ($null -eq $args[0] -or 
    $null -eq $args[1] -or
    $null -eq $args[2]) {
    Write-Error -Message "Please provide the dns, password and output path parameters " -ErrorAction Stop    
}


# Given parameter
$dns = $args[0]

#NOTE: RECOMMENDED TO BE AT LEAST 4 CHARS WITH:
# ONE UPPER CASE CHAR
# ONE LOWER CASE CHAR
# ONE SPECIAL CHAR (e.g. !,$,%,^ )
$password = $args[1]

$outputPath = $args[2]

# Configuration file content
$REQCONFIG = "[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
C = CountryName
ST = StateOrProvinceName
L = CityName
O = company
OU = Beslogic
CN = https://www.your-company.com/
[v3_req]
keyUsage = critical, digitalSignature, keyAgreement
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = $dns
DNS.2 = localhost"



# Generates configuration file

$ConfigFilePath = "$outputPath/req.cnf"
If (!(Test-Path $ConfigFilePath)) { New-Item -Path $ConfigFilePath -Force }
Add-Content -Path $ConfigFilePath -Value $REQCONFIG

# Creates key + certificate
$KeyFilePath = "$outputPath/company-$dns.key"
$CertificatePath = "$outputPath/company-$dns.crt"

openssl req -x509 -newkey rsa:4096 -sha256 -keyout $KeyFilePath -out $CertificatePath -subj "/CN=$dns" -days 3650 -config $ConfigFilePath -passin pass:$password -passout pass:$password

# Creates importable pfx file
$PFXFilePath = "$outputPath/$dns.pfx"
openssl pkcs12 -export -name "$dns" -out $PFXFilePath -inkey $KeyFilePath -in $CertificatePath -passin pass:$password -passout pass:$password;
