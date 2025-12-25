# Validate-IDCard.ps1

param(
    [Parameter(Mandatory = $true)]
    [string]$IDCard
)

function Test-ValidChineseIDCard {
    param([string]$IDCard)

    # === 1. 基本格式检查 ===
    if ($IDCard.Length -ne 18) { return $false }
    if ($IDCard -notmatch '^\d{17}[\dXx]$') { return $false }

    $areaCode = $IDCard.Substring(0, 6)
    $birthStr = $IDCard.Substring(6, 8)
    $checkBit = $IDCard.Substring(17, 1).ToUpper()

    # === 2. 省级前缀合法性（GB/T 2260）===
    $validProvinces = @(
        '11','12','13','14','15',
        '21','22','23',
        '31','32','33','34','35','36','37',
        '41','42','43','44','45','46',
        '50','51','52','53','54',
        '61','62','63','64','65',
        '71','81','82'
    )
    if ($validProvinces -notcontains $areaCode.Substring(0,2)) {
        return $false
    }

    # 排除明显无效的地区码
    if ($areaCode -eq '000000' -or $areaCode -eq '999999') {
        return $false
    }

    # === 3. 出生日期验证 ===
    try {
        $birthDate = [DateTime]::ParseExact($birthStr, 'yyyyMMdd', $null)
        if ($birthDate -lt [DateTime]'1900-01-01' -or $birthDate -gt (Get-Date)) {
            return $false
        }
    } catch {
        return $false
    }

    # === 4. 校验码验证 ===
    $weights = @(7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2)
    $checkCodes = @('1', '0', 'X', '9', '8', '7', '6', '5', '4', '3', '2')

    $sum = 0
    for ($i = 0; $i -lt 17; $i++) {
        $digit = [int]::Parse($IDCard.Substring($i, 1))
        $sum += $digit * $weights[$i]
    }
    $mod = $sum % 11
    $expectedCheckBit = $checkCodes[$mod]

    return ($checkBit -eq $expectedCheckBit)
}

# 主逻辑：调用函数并输出结果
$result = Test-ValidChineseIDCard -IDCard $IDCard
Write-Output $result