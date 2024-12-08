<#
.SYNOPSIS
Generates a QR code for a SEPA Credit Transfer (SCT) transaction.

.DESCRIPTION
This script generates a QR code for a SEPA Credit Transfer (SCT) transaction using the QRCoder library. The QR code is saved as a PNG file.

.PARAMETER BIC
The BIC (Bank Identifier Code) of the beneficiary's bank.

.PARAMETER IBAN
The IBAN (International Bank Account Number) of the beneficiary.

.PARAMETER BeneficiaryName
The name of the beneficiary.

.PARAMETER Amount
The amount to be transferred in EUR. Must be between 0.01 and 999999999.99.

.PARAMETER DueDate
The due date for the transaction.

.PARAMETER Reference
The reference for the transaction. Either this or the message must be provided.

.PARAMETER Message
The message for the transaction. Either this or the reference must be provided.

.PARAMETER OutputPNGFilePath
The output file path for the generated QR code PNG. Defaults to a file named SCTQRCode_<timestamp>.png in the script's directory.

.PARAMETER SaveToClipboard
Use this switch to save the QR code PNG to the clipboard.

.EXAMPLE
.\New-SCTQRCode.ps1 -BIC "DEUTDEFF" -IBAN "DE89370400440532013000" -BeneficiaryName "John Doe" -Amount 123.45 -DueDate "2023-12-31" -ReferenceNumber "RF18539007547034"

Generates a QR code for the specified SCT transaction and saves it as a PNG file.

.NOTES
Author: Henri Perämäki
Contact: peramhe.github.io

Requires the QRCoder.dll assembly to be present in the script's directory. This is included in the repository.
#>
Param(
    [Parameter(Mandatory=$true, HelpMessage="The BIC (Bank Identifier Code) of the beneficiary's bank.")]
    [string]$BIC,
    [Parameter(Mandatory=$true, HelpMessage="The IBAN (International Bank Account Number) of the beneficiary.")]
    [string]$IBAN,
    [Parameter(Mandatory=$true, HelpMessage="The name of the beneficiary.")]
    [string]$BeneficiaryName,
    [Parameter(Mandatory=$true, HelpMessage="The amount to be transferred in EUR.")]
    [ValidateScript({$_ -ge 0.01 -and $_ -le 999999999.99})]
    [double]$Amount,
    [Parameter(Mandatory=$true, HelpMessage="The due date for the transaction.")]
    [datetime]$DueDate,
    [Parameter(Mandatory=$true, ParameterSetName="Reference", HelpMessage="The reference for the transaction. Either this or the message must be provided.")]
    [string]$Reference,
    [Parameter(Mandatory=$true, ParameterSetName="Message", HelpMessage="The message for the transaction. Either this or the reference must be provided.")]
    [string]$Message,
    [Parameter(HelpMessage="The output file path for the generated QR code PNG.")]
    [string]$OutputPNGFilePath = "$PSScriptRoot\SCTQRCode_$(Get-Date -Format 'yyyyMMdd\_HHmmss').png",
    [Parameter(HelpMessage="Use this switch to save the QR code PNG to the clipboard.")]
    [switch]$SaveToClipboard
)

$ErrorActionPreference = 'Stop'

# Load QRCoder.dll assembly
$QRCoderDLLPath = "$PSScriptRoot\QRCoder.dll"
$DllBytes = [System.IO.File]::ReadAllBytes($QRCoderDLLPath)
[System.Reflection.Assembly]::Load($DLLBytes) | Out-Null

# Instantiate QRCodeGenerator
$QRCodeGenerator = [QRCoder.QRCodeGenerator]::new()

# Format SCT QR code payload
$SCTQRCodePayload = @"
BCD
001
1
SCT
$BIC
$BeneficiaryName
$IBAN
EUR$($Amount.ToString('F2', [System.Globalization.CultureInfo]::InvariantCulture))

$Reference
$Message
ReqdExctnDt/$($DueDate.ToString('yyyy\-MM\-dd'))
"@

# Create data layer presentation of the QR code
$QRCodeData = $QRCodeGenerator.CreateQrCode($SCTQRCodePayload, [QRCoder.QRCodeGenerator+ECCLevel]::M)

# Render the QR Code as a PNG graphic 
$PngByteQRCode = [QRCoder.PngByteQRCode]::new($QRCodeData)

# Return the graphic as a byte array with 20 pixel module size
$PngByteArray = $PngByteQRCode.GetGraphic(20)

# Save the PNG to the specified file path or clipboard
If ($SaveToClipboard) {
    [Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
    $stream = New-Object System.IO.MemoryStream(,$PngByteArray)
    $image = [System.Drawing.Image]::FromStream($stream)
    [Windows.Forms.Clipboard]::SetImage($image)
} else {
    [System.IO.File]::WriteAllBytes($OutputPNGFilePath, $PngByteArray)
}


