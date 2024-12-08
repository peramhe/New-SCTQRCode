# New-SCTQRCode

This PowerShell script generates a QR code for a SEPA Credit Transfer (SCT) transaction using the QRCoder library. The QR code is saved as a PNG file or can be copied to the clipboard.

**Read the related blog post here:**  
[How to generate SEPA Credit Transfer (SCT) QR codes using PowerShell | An IT consultants's (b)log](https://peramhe.github.io/posts/How-to-generate-SEPA-Credit-Transfer-(SCT)-QR-codes-using-PowerShell)

## Requirements

- PowerShell 5.1 or later
- QRCoder.dll (included in the repository is a version 1.6.0 targeting .NET 4.0)

## Parameters

`-BIC` (string): The BIC (Bank Identifier Code) of the beneficiary's bank. (Mandatory)  
`-IBAN` (string): The IBAN (International Bank Account Number) of the beneficiary. (Mandatory)  
`-BeneficiaryName` (string): The name of the beneficiary. (Mandatory)  
`-Amount` (double): The amount to be transferred in EUR. Must be between 0.01 and 999999999.99. (Mandatory)  
`-DueDate` (datetime): The due date for the transaction. (Mandatory)  
`-Reference` (string): The reference number for the transaction. Either this or the message must be provided. (Mandatory if `-Message` is not provided)  
`-Message` (string): The message for the transaction. Either this or the reference number must be provided. (Mandatory if `-Reference` is not provided)  
`-OutputPNGFilePath` (string): The output file path for the generated QR code PNG. Defaults to a file named `SCTQRCode_<timestamp>.png` in the script's directory.  
`-SaveToClipboard` (switch): Use this switch to save the QR code PNG to the clipboard.  

## Usage

**Syntax:**
```
New-SCTQRCode.ps1 -BIC <String> -IBAN <String> -BeneficiaryName <String> -Amount <Double>
-DueDate <DateTime> -Reference <String> [-OutputPNGFilePath <String>] [-SaveToClipboard]
```
**Example:**
```powershell
.\New-SCTQRCode.ps1 -BIC OKOYFIHH -IBAN FI7944052020036082 -BeneficiaryName "Acme Corporation" -Amount 397.49 -DueDate "2024-12-24" -Reference "241018" -SaveToClipboard
```

## Links

[codebude/QRCoder: A pure C# Open Source QR Code implementation](https://github.com/codebude/QRCoder)
